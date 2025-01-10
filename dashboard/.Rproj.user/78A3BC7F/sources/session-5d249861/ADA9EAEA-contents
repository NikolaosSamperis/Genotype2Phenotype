library(shiny)
library(DBI)
library(RMySQL)
library(ggplot2)
library(plotly)
library(dplyr)
library(scales)

# Define a custom transformation for the y-axis
custom_y_transform <- trans_new(
  name = "custom_y",
  transform = function(y) {
    ifelse(y <= 0.0001, y / 0.0001 * 0.25, 0.25 + (y - 0.0001) * 0.75 / 0.9999)
  },
  inverse = function(y) {
    ifelse(y <= 0.25, y * 0.0001 / 0.25, 0.0001 + (y - 0.25) * 0.9999 / 0.75)
  }
)

# Define UI
phenotype_significance_ui <- fluidPage(
  titlePanel(
    HTML("<span style='font-family: Arial; font-size: 20px; 
         font-weight: italic;'>Phenotype Significance on Knockout Mouse</span>")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 6, 
      selectInput("gene_symbol", "Gene Symbol", choices = NULL),
      selectInput("mouse_strain", "Mouse Strain", choices = NULL),
      selectInput("mouse_life_stage", "Mouse Life Stage", choices = NULL),
      actionButton("update_plot", "Run")
    ),
    
    mainPanel(
      plotlyOutput("plot", height = "600px"), 
      verbatimTextOutput("click_info"),      
      width = 12
    )
  )
)

# Define Server
phenotype_significance_server <- function(input, output, session) {
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
  
  # Populate dropdown menus with distinct values from database
  observe({
    updateSelectInput(session, "gene_symbol", 
                      choices = dbGetQuery(con, "SELECT DISTINCT 
                                           UPPER(gene_symbol) as gene_symbol 
                                           FROM analysis")$gene_symbol)
    updateSelectInput(session, "mouse_strain", 
                      choices = dbGetQuery(con, "SELECT DISTINCT 
                                           UPPER(mouse_strain) as mouse_strain 
                                           FROM analysis")$mouse_strain)
    updateSelectInput(session, "mouse_life_stage", 
                      choices = dbGetQuery(con, "SELECT DISTINCT 
                                           UPPER(mouse_life_stage) as mouse_life_stage 
                                           FROM analysis")$mouse_life_stage)
  })
  
  # Query the database based on user input and filter pvalue
  filtered_data <- eventReactive(input$update_plot, {
    query <- paste0(
      "SELECT UPPER(a.parameter_id) AS parameter_id,
        CONCAT(UCASE(SUBSTRING(a.parameter_name, 1, 1)), 
            LOWER(SUBSTRING(a.parameter_name, 2))) AS parameter_name,
        CONCAT(UCASE(SUBSTRING(pdg.parameter_description, 1, 1)), 
            LOWER(SUBSTRING(pdg.parameter_description, 2))) AS parameter_description,
        CONCAT(UCASE(SUBSTRING(pg.group_name, 1, 1)), 
            LOWER(SUBSTRING(pg.group_name, 2))) AS group_name,
        CONCAT(UCASE(SUBSTRING(prg.procedure_name, 1, 1)), 
            LOWER(SUBSTRING(prg.procedure_name, 2))) AS procedure_name,
        a.pvalue
        FROM analysis a
        LEFT JOIN parameter_description_grouped pdg ON a.parameter_id = pdg.parameter_id
        LEFT JOIN parameter_groups pg ON a.parameter_name = pg.parameter_name
        LEFT JOIN procedures_grouped prg ON 
        pdg.impcParameterOrigIds_groupId = prg.impcParameterOrigIds_groupId
        WHERE a.gene_symbol = '", input$gene_symbol, "' AND 
              a.mouse_strain = '", input$mouse_strain, "' AND 
              a.mouse_life_stage = '", input$mouse_life_stage, "'"
    )
    result <- dbGetQuery(con, query) %>%
      mutate(Significance = ifelse(pvalue < 0.0001, "Significant", "Not Significant"))
  })
  
  # Generate Plot
  output$plot <- renderPlotly({
    data <- filtered_data()
    if (nrow(data) == 0) {
      ggplot() +
        geom_text(aes(x = 0.5, y = 0.5, label = "No data available for the selection.")) +
        theme_void()
    } else {
      # Generate unique colors for groups
      group_colors <- data %>%
        distinct(group_name) %>%
        mutate(color = scales::hue_pal()(n_distinct(group_name)))
      
      data <- left_join(data, group_colors, by = "group_name")
      
      data$group_name <- factor(data$group_name, levels = unique(data$group_name))
      
      plot <- ggplot(data, aes(
        x = group_name, 
        y = pvalue, 
        color = group_name, 
        text = paste("Phenotype: ", parameter_name, "<br>P-Value: ", pvalue, "<br>Group: ", group_name)
      )) +
        geom_point(size = 2) +
        geom_hline(yintercept = 0.00099, linetype = "dotted", color = "black") +
        scale_color_manual(values = setNames(group_colors$color, group_colors$group_name)) +
        scale_y_continuous(
          trans = custom_y_transform,
          breaks = c(seq(0, 0.0001, by = 0.00001), seq(0.05, 1, by = 0.05)),
          labels = c(sprintf("%.5f", seq(0, 0.0001, by = 0.00001)), seq(0.05, 1, by = 0.05))
        ) +
        labs(
          title = "",
          x = "",
          y = "P-Value",
          color = "   Groups\n"
        ) +
        theme_minimal() +
        theme(
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank()
        ) 
      
      ggplotly(plot, tooltip = "text") %>% event_register("plotly_click")
    }
  })
  
  output$click_info <- renderText({
    # Ensure data is available and the plot has been rendered
    data <- filtered_data()
    req(nrow(data) > 0)  # Ensures there's data to plot
    
    # Capture click event
    click <- event_data("plotly_click")
    
    # Default message if no click event
    if (is.null(click)) {
      return("Click on a point to see details.")
    }
    
    # Ensure group_name is treated as a factor
    data$group_name <- factor(data$group_name, levels = unique(data$group_name))
    
    # Reverse the transformation of y to get the original pvalue
    original_pvalue <- custom_y_transform$inverse(click$y)
    
    # Map numeric x-position to group_name
    x_index <- round(click$x)  # Round to get the nearest x-index
    
    if (x_index >= 1 && x_index <= length(levels(data$group_name))) {
      clicked_group <- levels(data$group_name)[x_index]
      
      # Filter for the clicked group and original pvalue
      clicked_point <- data %>%
        filter(
          group_name == clicked_group,
          abs(pvalue - original_pvalue) < 0.00001
        )
      
      if (nrow(clicked_point) > 0) {
        # Format the output with line breaks
        paste(
          "Phenotype: ", clicked_point$parameter_name[1],
          "\nPhenotype ID: ", clicked_point$parameter_id[1],
          "\nPhenotype Description: ", 
          ifelse(clicked_point$parameter_description[1] == "" || 
                   is.na(clicked_point$parameter_description[1]), 
                 "No description available", 
                 clicked_point$parameter_description[1]),
          "\nPhenotype Procedure: ", clicked_point$procedure_name[1],
          "\nP-Value: ", sprintf("%.7f", clicked_point$pvalue[1])
        )
      } else {
        "Click on a point to see details."
      }
    } else {
      # Reset message when clicking outside valid group ranges
      "Click on a point to see details."
    }
  })
}
