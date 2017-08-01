shinyUI(
   navbarPage("", theme = shinytheme("flatly"), fluid = TRUE,
      tabPanel("Introduction",
          h4("Where Do Capital Region Homeowners Spend Their Housing Dollars? Hint: It's Not Where They Work"
             ),
            HTML("<div style='float:left'><a href='https://twitter.com/ukacz''>URSULA KACZMAREK  /  JULY 31, 2017
               </a></div>"),
       br(),
       br(),
       fluidRow(
        column(width = 8, offset = 2,
          h5("Homeowners in the Capital Region pay on average $1105 a month to own their homes.
            Costs vary greatly within the region, from a median monthly cost of $246 within
            the 12866 ZIP code to $3268 within the 12159 ZIP code."
             ),
          h5("Where residents spend their housing dollars tells us alot about
            about the economic (and environmental, as it turns out) dynamics
            in the Captial Region. Regression analysis provides us with useful
            insights about the intangible neighborhood characteristics that correlate
            to housing costs, and, in turn, the role suburbs and exurbs play."
             ),
          h5("From an initial pool of over 90 socioeconomic and geographic variables contained
            in the Center for Neighborhood Technology's H+T Index and the EPA's Smart Location Database,
            five emerged as the most informative:"
             ),
        tags$ul(
          tags$li("The number of high-wage ($3333 or higher per month) workers living there"),
          tags$li("Annual greenhouse gas emissions from household automobile use (metric tons)"),
          tags$li("The number of housing units per acre"),
          tags$li("The number of jobs available within a 45-minute drive"),
          tags$li("The percentage of dwellings that are owner occupied")
             ),
        HTML("<h5>The regression model has an adjusted R <sup>2</sup> of .66, which
             indicates these five factors explain 66 percent of the variability in monthly
             housing costs within the Capital Region.</h5>"
             ),
         h5("Below are scatterplots demonstrating the relationship between each of the factors
            and monthly housing costs. Each dot represents a block group, the smallest
            geographical unit contained within U.S. Census Bureau data, which roughly
            corresponds to a single neighborhood."
             )
       )
       ),
        br(),
        HTML("<h5><em><span style=color:#228f8c>mouse over graphs for details</span></em><h5>"),
        div(
           style = "position:relative",
           plotOutput("plot.matrix", hover = hoverOpts("plot.hover", delay = 10, delayType = "debounce")),
           uiOutput("hover.info")
        ),
       br(),
       fluidRow(
        column(width = 8, offset = 2,
         h5("The negative relationship between housing costs and the jobs availability
            variable indicates the areas playing host to many jobs (in particular the City of Albany)
            are not the areas where workers spend their housing dollars. Regression
            does not definitively tell us whether this spatial mismatch arises from residents'
            desire to live outside the city by choice or from a lack of affordable
            housing in urban neighborhoods. However, we can infer from the high concentrations
            of high-wage workers living in suburban and exurban areas that the former is
            the likelier case."
            ),
         HTML("<h5>One notable consequence of the jobs and housing location imbalance
            in the Capital Region is
            <a href=http://news.berkeley.edu/2014/01/06/suburban-sprawl-cancels-carbon-footprint-savings-of-dense-urban-cores/>
            typical of other metropolitan areas</a>: the suburban and exurban areas
            that serve as residential neighborhoods are bigger generators of automobile greenhouse
            gas emissions in the region than those in the urban core. Residents of these less
            dense neighborhoods drive more to access jobs and services
            than do their urban counterparts.</h5>"
            ),
         HTML("<h5>Driving more increases a household's transportation costs, but
            Capital Region residents are paying more for housing in areas
            that entail higher transportation costs. The Capital Region's housing patterns
            mirror those of <a href=http://www.pewtrusts.org/en/research-and-analysis/blogs/stateline/
            2015/4/15/returning-to-the-exurb-rural-counties-are-fastest-growing>
            cities experiencing exurban housing growth</a>, where residents are willing
            to sacrifice shorter commutes for <a href=https://www.curbed.com/2017/6/20/15834514/
            rent-transportation-commute-affordable-housing>'a lawn, marble countertops, and a good school district.'</a></h5>"
            ),
         HTML("<h5><strong>Click on the header tabs to view the factors mapped out across the region and
            to access the data.</strong></h5>")
         )
        ),
        br(),
      HTML("<h5>To run the regression models and view the application source code, visit
           <a href=https://github.com/ursulakaczmarek/alb.housing.costs/> the GitHub page</a>.</h5>"
           )
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
