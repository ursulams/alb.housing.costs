ui <- shinyUI(
 navbarPage("How do Neighborhood Characteristics Relate Monthly Housing Costs in the Capital Region?", theme = shinytheme("flatly"),
             fluid = TRUE,
      tabPanel("Analysis",
            HTML("<div style='float:right'><a href='https://twitter.com/ukacz''>URSULA KACZMAREK  /  JULY 10, 2017
               </a></div>"),
        br(),       
        h4("Housing affordability remains a constant concern for many metro regions in the US,
          including the Capital Region. Homeowners in the Albany-Schenectady-Troy
          core-based statistical area pay on average $1105 in monthly housing costs, with renters
          shelling out $871 per month. Costs vary greatly within the region, from  
          a median monthly cost of $246 within the 12866 ZIP code to $3268 within the 12159 ZIP code."),
        br(),
        h4("Tangible factors like the size and condition of dwellings undoubtedly influence
          monthly homeowner costs, but what about intangible factors like neighborhood characteristics?
          Regression analysis can provide us with useful insights to better understand 
          what intangibles correlate to monthly housing costs in the Capital Region."), 
        br(),  
        h4("From an initial pool of over 90 socioeconomic and geographic variables contained
            in the Center for Neighborhood Technology's H+T Index and the EPA's Smart Location Database,
            seven emerged as the most correlated:"),
        br(),
        tags$ul(
          tags$li("The population of the block group"),
          tags$li("The size of the neighborhood (in acres)"),
          tags$li("Annual greenhouse gas emissions from household automobile use (metric tons)"),
          tags$li("The percentage of dwellings that are owner occupied"),
          tags$li("The number of low-wage ($1250 or less per month) workers living there"),
          tags$li("The number of high-wage ($3333 or higher per month) workers living there"),
          tags$li("The number of jobs available within a 45-minute drive (weighted by block group jobs per household)")
          ),        
        br(),
        HTML("<h4>The regression model has an adjusted R <sup>2</sup> of .6929, which 
             indicates these five factors explain about 69 percent of the variability in monthly 
             housing costs for the Capital Region.</h4>"),
        br(),
        h4("Below are scatterplots demonstrating the relationship between each of the seven factors
           and monthly housing costs. Each dot represents a block group, the smallest 
           geographical unit contained within U.S. Census Bureau data, and the line of best
           fit is a linear "),

        br(),
        HTML("<h5><em><span style=color:#228f8c>mouse over graphs for details</span></em><h5>"),
      div(
        style = "position:relative",
        plotOutput("plot.matrix", hover = hoverOpts("plot.hover", delay = 10, delayType = "debounce")),
        
        uiOutput("hover.info")
        ),
      h4("The relationship between monthly housing costs and the factors are easy to observe
          on the scatterplots below. 
         (...)  
         housing costs increase alongside annual household greenhouse gas emissions. 
         This suggests houses tend to cost more in areas where one needs to drive more or where 
         residents own more cars."),
      br(),
      HTML("<h4>For more information on the regression model outputs, the data, and the 
           code behind the visualizations, visit
           <a href=https://github.com/ursulakaczmarek/alb.housing.costs/> the GitHub page</a>.</h4>")
           ),
      
      tabPanel("Map",
               tags$style("html, body {width:100%;height:100%}"),
          leafletOutput("map", height = "900px"),
          absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                  draggable = TRUE, top = 70, left = "auto", right = 10, bottom = "auto",
                  width = 400, height = 75,
                        selectInput("vars", "select a factor", factors, width = "400px")
            )
          ),
      
      tabPanel("Data",
                actionButton("export", "export the data", class = "btn-success"),
              hr(),
              DT::dataTableOutput("data.out")
              ),
      tags$div(id = "citation",
               "Data:", a(href="http://htaindex.cnt.org/about/","H+T Index,"),
               "Center for Neighborhood Technology;", 
               a(href="https://www.epa.gov/smartgrowth/smart-location-mapping#SLD",
                 "Smart Location Database,"), "U.S. EPA."
      )
 )
)
  
