library(shiny)

# Load experiment-specific modules
source("phenotype_significance.R", local = TRUE)  
source("gene_significance.R", local = TRUE)      
source("gene_clustering.R", local = TRUE)        

# Main App UI
ui <- fluidPage(
  # Title Panel with additional info
  fluidRow(
    column(12, align = "center",
           # This is where you define the content inside the column
           titlePanel("Genome to Phenome: Integrated Framework for Gene Expression in Mus Musculus"),
           div(
             HTML("<h3>Data Cleaning and Data Management Project - Group #9</h3>"),
             HTML("<h4>Bhargav Pulugundla - K24058189, Nikolaos Samperis - K24105804</h4>"),
             HTML("<h4>Aidan Saldanha - K24090140, Harit Kohli - K24052661</h4>")
           )
      )
  ),
  
  tags$br(),
  
  # Sidebar Layout centered on the page
  fluidRow(
    column(2),  # Empty column for spacing (left)
    column(8,   # Centered column for the sidebar
           sidebarPanel(
             width = 12,
             selectInput(
               "experiment", 
               "Choose the type of visualisation", 
               choices = list(
                 "--" = "--", 
                 "Statistical scores of all phenotypes tested on 
                 a selected knockout mouse" = "Phenotype Significance", 
                 "Statistical scores of all knockout mice for a 
                 selected phenotype" = "Gene Significance", 
                 "Clusters of genes with similar phenotype scores" 
                 = "Gene Clustering"
               ),
               selected = "--" 
             )
           )
    ),
    column(3)  # Empty column for spacing (right)
  ),
  
  # Main Panel
  fluidRow(
    column(12,
           mainPanel(
             uiOutput("dynamic_ui"),  # Placeholder for dynamically loaded experiment UI
             width = 12
           )
    )
  )
)


# Main App Server
server <- function(input, output, session) {
  # Reactive variable to store the current module's server function
  current_server <- reactiveVal(NULL)
  
  # Dynamic UI rendering based on selected experiment
  output$dynamic_ui <- renderUI({
    req(input$experiment)
    
    if (input$experiment == "Phenotype Significance") {
      phenotype_significance_ui
    } else if (input$experiment == "Gene Significance") {
      gene_significance_ui
    } else if (input$experiment == "Gene Clustering") {
      gene_clustering_ui
    }
  })
  
  # Observing the selected experiment and dynamically calling the respective server
  observe({
    req(input$experiment)
    
    if (input$experiment == "Phenotype Significance") {
      current_server(function(input, output, session) {
        phenotype_significance_server(input, output, session)
      })
    } else if (input$experiment == "Gene Significance") {
      current_server(function(input, output, session) {
        gene_significance_server(input, output, session)
      })
    } else if (input$experiment == "Gene Clustering") {
      current_server(function(input, output, session) {
        gene_clustering_server(input, output, session)
      })
    }
  })
  
  # Dynamically call the selected experiment's server logic
  observe({
    req(current_server())
    current_server()(input, output, session)
  })
}

# Run the main app
shinyApp(
  ui = ui,
  server = server,
  options = list(launch.browser = TRUE)
)
