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
gene_significance_ui <- fluidPage(
  titlePanel(
    HTML("<span style='font-family: Arial; font-size: 20px; 
         font-weight: italic;'>Gene Significance on Phenotypes</span>")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 6, 
      selectInput("phenotype", "Phenotype", choices = NULL),
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
gene_significance_server <- function(input, output, session) {
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
  
  #updateSelectInput(session, "gene_symbol", 
  #                 choices = c("ap1ar", "trpm7", "eps15", "avp"), 
  #                 selected = "ap1ar")
  
  # Populate dropdown menus with distinct values from database
  observe({
    updateSelectInput(session, "phenotype", 
                      choices = dbGetQuery(con, "SELECT DISTINCT 
                                           CONCAT(UCASE(SUBSTRING(parameter_name, 1, 1)), 
                                           LOWER(SUBSTRING(parameter_name, 2))) AS parameter_name
                                           FROM analysis")$parameter_name)
  })
  
  # Query the database based on user input and filter pvalue
  filtered_data <- eventReactive(input$update_plot, {
    query <- paste0(
      "SELECT UPPER(a.gene_symbol) AS gene_symbol,
        UPPER(a.gene_accession_id) AS gene_accession_id,
        UPPER(a.mouse_strain) AS mouse_strain,
        UPPER(a.mouse_life_stage) AS mouse_life_stage, 
        cg.chromosome,
        a.pvalue, 
        CONCAT(UCASE(SUBSTRING(pg.group_name, 1, 1)), 
            LOWER(SUBSTRING(pg.group_name, 2))) AS group_name 
        FROM analysis a
        LEFT JOIN parameter_groups pg ON a.parameter_name = pg.parameter_name
        LEFT JOIN chromosome_gene cg ON a.gene_accession_id = cg.gene_accession_id 
                                     AND a.gene_symbol = cg.gene_symbol
        WHERE a.parameter_name = '", input$phenotype, "'"
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
      # Generate unique colors for chromosomes
      chromosome_colors <- data %>%
        distinct(chromosome) %>%
        mutate(color = scales::hue_pal()(n_distinct(chromosome)))
      
      # Ensure chromosomes are ordered numerically
      data <- left_join(data, chromosome_colors, by = "chromosome")
      
      # Convert 'chromosome' to a factor, ensuring the order is numeric (if it is numeric-like)
      data$chromosome <- factor(data$chromosome, levels = unique(data$chromosome[order(as.numeric(data$chromosome))]))
      
      plot <- ggplot(data, aes(
        x = chromosome, 
        y = pvalue, 
        color = chromosome, 
        text = paste("Gene Symbol: ", gene_symbol, "<br>P-Value: ", pvalue)
      )) +
        geom_point(size = 2) +
        geom_hline(yintercept = 0.00099, linetype = "dotted", color = "black") +
        scale_color_manual(values = setNames(chromosome_colors$color, chromosome_colors$chromosome)) +
        scale_y_continuous(
          trans = custom_y_transform,
          breaks = c(seq(0, 0.0001, by = 0.00001), seq(0.05, 1, by = 0.05)),
          labels = c(sprintf("%.5f", seq(0, 0.0001, by = 0.00001)), seq(0.05, 1, by = 0.05))
        ) +
        labs(title = "", x = "", y = "P-Value", color = "Chromosomes\n") +
        theme_minimal() + 
        theme(
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank()
        )
      
      ggplotly(plot, tooltip = "text") %>% event_register("plotly_click")
    }
  })
  
  output$click_info <- renderText({
    # Capture click event
    click <- event_data("plotly_click")
    
    # Default message if no click event
    if (is.null(click)) {
      return("Click on a point to see details.")
    }
    
    # Extract reactive data
    data <- filtered_data()
    
    # Ensure chromosome is treated as a factor with ordered levels
    data$chromosome <- factor(data$chromosome, levels = unique(data$chromosome[order(as.numeric(data$chromosome))]))
    
    # Inverse transformation of y-axis (p-value)
    original_pvalue <- custom_y_transform$inverse(click$y)
    
    # Map x-axis index to chromosome
    x_index <- round(click$x)
    
    if (x_index >= 1 && x_index <= length(levels(data$chromosome))) {
      # Find the clicked chromosome
      clicked_chromosome <- levels(data$chromosome)[x_index]
      
      # Filter data for matching chromosome and p-value within tolerance
      clicked_point <- data %>%
        filter(chromosome == clicked_chromosome)
      
      if (nrow(clicked_point) > 0) {
        # Find the row with the closest pvalue to the original_pvalue
        closest_point <- clicked_point %>%
          mutate(diff = abs(pvalue - original_pvalue)) %>%
          arrange(diff) %>%
          slice(1)  # Select the closest point
        
        # Create message with the closest point
        paste(
          "Gene Symbol: ", closest_point$gene_symbol,
          "\nGene Accession ID: ", closest_point$gene_accession_id,
          "\nChromosome: ", closest_point$chromosome,
          "\nGroup: ", closest_point$group_name,
          "\nMouse Strain: ", closest_point$mouse_strain,
          "\nMouse Life Stage: ", closest_point$mouse_life_stage,
          "\nP-Value: ", sprintf("%.7f", closest_point$pvalue)
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
