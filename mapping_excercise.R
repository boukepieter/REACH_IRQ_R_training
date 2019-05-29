library(leaflet)
library(htmlwidgets)

data <- read.csv("DTM.csv", stringsAsFactors = F)
data <- data[-nrow(data),]
data$Families <- as.numeric(data$Families)
data2 <- data[which(data$Anbar > 0),]

m <- leaflet() %>% 
  addTiles(#"http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png",
    # attribution = paste(
    #   "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors",
    #   "&copy; <a href=\"http://cartodb.com/attributions\">CartoDB</a>"
    # )
  ) %>%
  setView(44, 36, zoom = 10) %>% 
  #addMarkers(data=data, lng=~Longitude, lat=~Latitude, label=~Families, clusterOptions = markerClusterOptions()) 
  addCircleMarkers(data=data, lng=~Longitude, lat=~Latitude, radius=~sqrt(Families), 
                   popup=sprintf("Name: %s; IDP's:%s",data$Location.Name, as.character(data$Families)),
                   popupOptions = popupOptions(maxWidth="100%",closeOnClick=T),
                   color = ifelse(data$Camp > 0, "red", "blue")) %>% 
  addMarkers(data=data2, lng=~Longitude, lat=~Latitude,  
                   popup=sprintf("Amount of IDP's from Anbar: %s", as.character(data2$Anbar))) %>% 
  addLegend(position="topright",colors=c("red","blue"),
            labels=c("Camp location","Out of camp location"))

saveWidget(m,"map.html")


