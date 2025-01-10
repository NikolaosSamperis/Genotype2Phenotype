library(shiny)
library(DBI)
library(RMySQL)
library(ggplot2)
library(plotly)
library(dplyr)
library(tidyr)
library(umap)
library(shinycssloaders)

# Define UI
gene_clustering_ui <- fluidPage(
  titlePanel(
    HTML("<span style='font-family: Arial; font-size: 20px; 
         font-weight: italic;'>Clustering of Gene Symbols on Significance Score</span>")
  ),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("num_clusters", "Number of Clusters:", value = 5, min = 2, max = 15, step = 1),
      actionButton("update_plot", "Run"),
      width = 2
    ),
    
    mainPanel(
      withSpinner(plotlyOutput("cluster_plot", height = "600px")),
      verbatimTextOutput("click_info"),
      width = 9
    )
  )
)

# Define Server
gene_clustering_server <- function(input, output, session) {
  # Establish a database connection
  con <- dbConnect(
    RMySQL::MySQL(),
    dbname = "dcdm_project_group9",
    host = "localhost",
    user = "barry",
    password = "push12@KCL"
  )
  
  onStop(function() {
    dbDisconnect(con)  # Ensure connection is closed
  })
  
  # Reactive data filtered from the database
  filtered_data <- eventReactive(input$update_plot, {
    query <- "SELECT UPPER(a.gene_symbol) AS gene_symbol,
              CONCAT(UCASE(SUBSTRING(a.parameter_name, 1, 1)), 
                     LOWER(SUBSTRING(a.parameter_name, 2))) AS parameter_name, 
              a.pvalue,
              CONCAT(UCASE(SUBSTRING(pg.group_name, 1, 1)), 
                     LOWER(SUBSTRING(pg.group_name, 2))) AS group_name 
              FROM analysis a
              LEFT JOIN parameter_groups pg ON a.parameter_name = pg.parameter_name"
    dbGetQuery(con, query)
  })
  
  # Reactive expression to prepare UMAP data
  umap_data <- eventReactive(input$update_plot, {
    data <- filtered_data()
    
    if (is.null(data) || nrow(data) == 0) {
      return(NULL)
    }
    
    # Filter for significant genes
    data <- data %>%
      filter(!is.na(pvalue), pvalue < 0.0001)
    
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    # Prepare phenotype data and group IDs
    data <- data %>%
      group_by(group_name) %>%
      mutate(group_id = as.integer(factor(group_name))) %>%
      ungroup()
    
    # Scale phenotype data for UMAP
    umap_input <- scale(data$pvalue)
    umap_result <- umap(umap_input, n_neighbors = 15, min_dist = 0.1, metric = "euclidean")
    
    num_clusters <- input$num_clusters  # User-defined cluster count
    
    # Apply k-means clustering to UMAP results
    umap_clusters <- kmeans(umap_result$layout, centers = num_clusters)$cluster
    
    data <- data %>%
      mutate(
        umap_x = umap_result$layout[, 1],
        umap_y = umap_result$layout[, 2],
        cluster = factor(umap_clusters)  # Assign clusters
      )
    
    # Space clusters apart by adding offsets based on group IDs
    data <- data %>%
      group_by(cluster) %>%
      mutate(
        umap_x = umap_x + group_id * 15,  # Offset clusters on x-axis
        umap_y = umap_y + group_id * 15   # Offset clusters on y-axis
      ) %>%
      ungroup()
    
    return(data)
  })
  
  # Plotly output using UMAP data
  output$cluster_plot <- renderPlotly({
    data <- umap_data()
    
    if (is.null(data) || nrow(data) == 0) {
      showNotification("No data available for clustering!", type = "error")
      return(NULL)
    }
    
    # Visualize significant genes with UMAP
    plot <- ggplot(data, aes(
      x = umap_x, y = umap_y, color = cluster, text = paste(
        "Gene Symbol:", gene_symbol,
        "<br>Group:", group_name,
        "<br>P-Value:", sprintf("%.5f", pvalue)
      )
    )) +
      geom_point(size = 2, alpha = 0.8) +
      scale_color_manual(values = scales::hue_pal()(length(unique(data$cluster)))) +
      labs(
        title = "",
        x = "",
        y = "",
        color = "Clusters\n"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.position = "right"
      )
    
    ggplotly(plot, tooltip = "text")
  })
  
  # Click information using UMAP data
  output$click_info <- renderText({
    click <- event_data("plotly_click")
    
    if (is.null(click)) {
      return("Click on a point to see details.")
    }
    
    # Use the UMAP data reactive expression
    data <- umap_data()
    
    if (is.null(data)) {
      return("No data available.")
    }
    
    # Match the closest point based on the clicked coordinates
    clicked_point <- data %>%
      mutate(
        distance = sqrt((umap_x - click$x)^2 + (umap_y - click$y)^2)
      ) %>%
      filter(distance == min(distance))
    
    if (nrow(clicked_point) > 0) {
      paste(
        "Gene Symbol: ", clicked_point$gene_symbol[1],
        "\nPhenotype: ", clicked_point$parameter_name[1],
        "\nGroup Name: ", clicked_point$group_name[1],
        "\nP-Value: ", sprintf("%.7f", clicked_point$pvalue[1])
      )
    } else {
      "Click on a point to see details."
    }
  })
}
