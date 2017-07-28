server <- shinyServer(function(input, output, session){

# analysis
variables <- zip.data %>% gather(var, value, c(4:5, 7:10, 13)) %>% 
  select(-jobs.per.household, -jobs.within.45.drive)

output$plot.matrix <- renderPlot({
  ggplot(variables, aes(x = value, y = sqrt(housing.cost), color = housing.cost), 
         main = "monthly housing cost vs. top regression variables") +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "navy", size = 0.3) +
    facet_grid(. ~ var, scales = "free") +
    scale_color_viridis() +
    theme_few() +
    theme(axis.title.x = element_blank())
  })  

output$hover.info <- renderUI({
  hover.1 <- input$plot.hover
  point.1 <- nearPoints(variables, hover.1, threshold = 2, maxpoints = 1, addDist = FALSE)
  if (nrow(point.1) == 0) return(NULL)
  
  left.pct <- (hover.1$x - hover.1$domain$left) / (hover.1$domain$right - hover.1$domain$left)
  top.pct <- (hover.1$domain$top - hover.1$y) / (hover.1$domain$top - hover.1$domain$bottom)
  
  left.px <- hover.1$range$left + left.pct * (hover.1$range$right - hover.1$range$left)
  top.px <- hover.1$range$top + top.pct * (hover.1$range$bottom - hover.1$range$top)
  
  style <- paste0("position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.75); ",
                  "left:", left.px - 2, "px; top:", top.px - 2, "px;")
  wellPanel(
    style = style,
    p(HTML(paste0("<b> block group: </b>", point.1$GEOID, "<br/>",
                  "<b> city: </b>", point.1$city, "<br/>",
                  "<b> zip: </b>", point.1$zip, "<br/>",
                  "<b> monthly housing cost: </b>$", point.1$housing.cost, "<br/>",
                  "<b> factor: </b>", point.1$var, "</br>",
                  "<b> value: </b>", point.1$value, "</br>")))
  )
})
  
# map    
selected <- reactive({
  blocks[blocks@data$factors == input$vars,]
})

output$map <- renderLeaflet({

  pal <- reactive({
  colorNumeric(palette = "viridis", domain = selected()$values)
  })
  
  maplabels <- paste0("<b>block group: </b>", selected()$GEOID, "<br/>",
                    sprintf("<b>%s: </b>%g", selected()$factors, selected()$values)) %>%
              lapply(htmltools:: HTML)
  
  leaflet() %>%
    setView(lng = -73.725, lat = 42.525, zoom = 9) %>%
    addPolygons(data = selected(), fillColor = ~pal()(values), fillOpacity = 0.8,
                stroke = TRUE, color = "#3498db", weight = 1, opacity = 0.7,
                highlight = highlightOptions(
                  weight = 1,
                  color = "#666",
                  dashArray = "",
                  fillOpacity = 0.7,
                  bringToFront = TRUE),
                label = maplabels,
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "3px 8px"),
                  textsize = "15px",
                  direction = "auto")) %>%
    addLegend(position = "topleft",
              pal = pal(), 
              values = selected()$values,
              title = "selected factor",
              opacity = .5) %>%
    addProviderTiles("Stamen.TonerLite")
  })


# data explorer
output$data.out <- renderDataTable({
  zip.data
  action <- dataTableAjax(session, zip.data)
  DT::datatable(zip.data, style = "bootstrap")
  })

observeEvent(input$export, {
 write.csv(zip.data, "alb.housing.cost.data.csv", row.names = FALSE)
})

})
