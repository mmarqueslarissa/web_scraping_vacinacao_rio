
# Objetivo desse script é raspar os dados de vacincão do Estado do Rio de Janeiro
## pacotes e instalacoes necessarias 
pacman::p_load(tidyverse, httr, webdriver, xml2, rvest)
webdriver::install_phantomjs() #apenas uma vez na vida
## ============================================================================

## Primeira tentativa - usar o pacote HTTR ======

u_vaci <- httr::GET("https://vacinacaocovid19.saude.rj.gov.br/vacinometro", 
                    httr::write_disk("~/Downloads/link_vacina.hmtl")) # Falhou

#### se eu extraio daqui eu vou ter uma pagina em branco pois a página é dinâmica com base em JavaScript

## Segunda tentativa - usar o PHANTOMJS =======

pjs <- run_phantomjs() #p/ abrir um navegador invisivel
pjs #indica onde esse navegador esta rodando - fala a porta

## comecar a interagir com o phantomJS - abrir uma sessao p/ de fato navegar
ses <- Session$new(port = pjs$port)
url <- "https://vacinacaocovid19.saude.rj.gov.br/vacinometro"

ses$go(url)
ses$takeScreenshot() #p/ saber que estou na pagina correta - sempre bom fazer isso 


# criar caminho XPath para filtrar apenas os dados dos 92 municípios

munis_92 <- ses$findElement(
  xpath = '//*[@class = "st1 map-svg" and @id]') 

munis_92$click()
ses$takeScreenshot()
html <- ses$getSource()
file <- fs::file_temp(ext = "html") # criar um arquivo temporario

readr::write_file(html, file)

table <- file%>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') #%>% vira um xml_nodeset
XML::xmlToDataFrame() # nao funcionca :(

table[[1]] # um {html_node} # acessar apenas o atributo do primeiro nó da lista de municípios (??)

## a etapa de parseamento está muito complicada pois o rvest::html_table não funciona :(

# Não conseguindo de uma forma automática, resolvi baixar um atributo por vez e depois junta-los em um DT

## ID

id <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("id")

id <- as_data_frame(id)
colnames(id) <- "id"

## PERCENT_D1

percent_d1 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("percent-d1")

percent_d1  <-as_data_frame(percent_d1)
colnames(percent_d1) <- "percent_d1"

## PERCENT_D2

percent_d2 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("percent-d2")

percent_d2 <- as_data_frame(percent_d2)
colnames(percent_d2) <- "percent_d2"

## PERCENT_DU

percent_du <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("percent-du")

percent_du <- as_data_frame(percent_du)
colnames(percent_du) <- "percent_du"

## MUNICIPIO NAME

municipio_name2 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("municipio-name")

municipio_name2 <- as_data_frame(municipio_name2)
colnames(municipio_name) <- "municipio_name"


## TOTAL POPULATION

total_population <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("total-population")

total_population <- as_data_frame(total_population)
colnames(total_population) <- "total_population"


## ESTIMATED POPULATION

estimated_population <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("estimated-population")

estimated_population <- as_data_frame(estimated_population)
colnames(estimated_population) <- "estimated_population"

## VACCINED COUNT D1

vaccined_count_d1 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("vaccined-count-d1")

vaccined_count_d1 <- as_data_frame(vaccined_count_d1)
colnames(vaccined_count_d1) <- "vaccined_count_d1"

## VACCINED COUNT D2

vaccined_count_d2 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("vaccined-count-d2")

vaccined_count_d2 <- as_data_frame(vaccined_count_d2)
colnames(vaccined_count_d2) <- "vaccined_count_d2"

## VACCINED COUNT DU 

vaccined_count_du <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("vaccined-count-du")

vaccined_count_du <- as_data_frame(vaccined_count_du)
colnames(vaccined_count_du) <- "vaccined_count_du"


## TOTAL DISTRIBUTED D1

total_distributed_d1 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("total-distributed-d1")

total_distributed_d1 <- as_data_frame(total_distributed_d1)
colnames(total_distributed_d1) <- "total_distributed_d1"

## TOTAL DISTRIBUTED D2

total_distributed_d2 <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("total-distributed-d2")

total_distributed_d2 <- as_data_frame(total_distributed_d2)
colnames(total_distributed_d2) <- "total_distributed_d2"

## TOTAL DISTRIBUTED DU

total_distributed_du <- file %>%
  xml2::read_html() %>% 
  xml2::xml_find_all('//*[@class= "st1 map-svg"]') %>% 
  xml2::xml_attr("total-distributed-du")

total_distributed_du <- as_data_frame(total_distributed_du)
colnames(total_distributed_du) <- "total_distributed_du"


## Juntar e salvar o banco em .csv ou .rda


vaccination_rio_de_janeiro <- cbind(id, percent_d1, 
                                    percent_d2, 
                                    percent_du, 
                                    municipio_name, 
                                    total_population, 
                                    estimated_population,
                                    vaccined_count_d1, 
                                    vaccined_count_d2,
                                    vaccined_count_du,
                                    total_distributed_d1, 
                                    total_distributed_d2, 
                                    total_distributed_du)


## Salvar a base - 

write_csv(vaccination_rio_de_janeiro, "vaccination_rio.csv") 

