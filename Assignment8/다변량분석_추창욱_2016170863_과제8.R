# Package for cluster validity
library(clValid)
library(plotrix)

# Part 1: K-Means Clustering ----------------------------------------------
# Load the credit data set
hero <- read.csv("mlbb_hero.csv")

role_list <- list('assassin', 'fighter', 'mage','marksman', 'support', 'tank')
n = 1
for (i in role_list) {
  hero[hero$role == i, 'role'] <- n
  n <- n + 1
}
str(hero)

# Remove the class label
hero_class <-hero[,2]
hero_x <- hero[,3:18]

##K_Means Clustering
hero_x_scaled <- as.data.frame(scale(hero_x, center = TRUE, scale = TRUE))
str(hero_x_scaled)

#Question2----------------------------------------------------------------------
start_time <- proc.time()
hero_clValid <- clValid(hero_x_scaled, 2:10, clMethods = "kmeans", validation = c("internal","stability"),maxitems = 10000)
end_time <- proc.time()
end_time - start_time

summary(hero_clValid)


#Question3----------------------------------------------------------------------
for(i in 1:10){
  cat("Number of Iteraion:",i,"\n")
  hero_tmp <- kmeans(hero_x_scaled, 4)
  
  print(hero_tmp$centers)
  print(hero_tmp$size)
}

#Question4----------------------------------------------------------------------
hero_kmc <- kmeans(hero_x_scaled,4)

real_class <- hero_class
kmc_cluster <- hero_kmc$cluster
table(real_class, kmc_cluster)

cluster_kmc <- data.frame(hero_x_scaled, clusterID = as.factor(hero_kmc$cluster))
kmc_summary <- data.frame()

for(i in 1:(ncol(cluster_kmc)-1)){
  kmc_summary = rbind(kmc_summary, tapply(cluster_kmc[,i],
                                          cluster_kmc$clusterID,mean))
}
colnames(kmc_summary) <- paste("cluster", c(1:4))
rownames(kmc_summary) <- colnames(hero_x)
kmc_summary

par(mfrow = c(2,2))
for(i in 1:4){
  plot_title <- paste("Radar Chart for Cluster",i, sep = " ")
  radial.plot(kmc_summary[,i], labels = rownames(kmc_summary),
              radial.lim = c(-2,3), rp.type = "p", main = plot_title,
              line.col = "red", lwd = 3, show.grid.labels = 1)
}




#Question5----------------------------------------------------------------------
kmc_cluster1 <- hero_x[hero_kmc$cluster == 1,]
kmc_cluster2 <- hero_x[hero_kmc$cluster == 2,]
kmc_cluster3 <- hero_x[hero_kmc$cluster == 3,]
kmc_cluster4 <- hero_x[hero_kmc$cluster == 4,]

kmc_t_result <- data.frame()
for(i in 1:16){
  if (kmc_cluster1[,i] == kmc_cluster2[,i]){
    kmc_t_result[i,1] <- "None"
  }
  else{
    kmc_t_result[i,1] <- t.test(kmc_cluster1[,i], kmc_cluster2[,i], alternative = "two.sided")$p.value
  }
  if (kmc_cluster1[,i] == kmc_cluster3[,i]){
    kmc_t_result[i,2] <- "None"
  }
  else{
    kmc_t_result[i,2] <- t.test(kmc_cluster1[,i], kmc_cluster3[,i], alternative = "two.sided")$p.value
  }
  if (kmc_cluster1[,i] == kmc_cluster4[,i]){
    kmc_t_result[i,3] <- "None"
  }
  else{
    kmc_t_result[i,3] <- t.test(kmc_cluster1[,i], kmc_cluster4[,i], alternative = "two.sided")$p.value
  }
  if (kmc_cluster2[,i] == kmc_cluster3[,i]){
    kmc_t_result[i,4] <- "None"
  }
  else{
    kmc_t_result[i,4] <- t.test(kmc_cluster2[,i], kmc_cluster3[,i], alternative = "two.sided")$p.value
  }
  
  if (kmc_cluster2[,i] == kmc_cluster4[,i]){
    kmc_t_result[i,5] <- "None"
  }
  else{
    kmc_t_result[i,5] <- t.test(kmc_cluster2[,i], kmc_cluster4[,i], alternative = "two.sided")$p.value
  }
  if (kmc_cluster3[,i] == kmc_cluster4[,i]){
    kmc_t_result[i,6] <- "None"
  }
  else{
    kmc_t_result[i,6] <- t.test(kmc_cluster3[,i], kmc_cluster4[,i], alternative = "two.sided")$p.value
  }
}

colnames(kmc_t_result) <- c("cluster1vs2","cluster1vs3","cluster1vs4","cluster2vs3","cluster2vs4","cluster3vs4")
kmc_t_result
write.csv(kmc_t_result, file = "question5.csv")

#Question6----------------------------------------------------------------------
hero_H <- hero[,3:18]
hero_H_scaled <- as.data.frame(scale(hero_H, center = TRUE, scale = TRUE))

start_time <- proc.time()
hero_clValid_H <- clValid(hero_H_scaled, 2:10, clMethods = "hierarchical", validation = c("internal","stability"),maxitems = 10000)
end_time <- proc.time()
end_time - start_time

summary(hero_clValid_H)

cor_Mat <- cor(t(hero_H_scaled), method = "spearman")
dist_hero <- as.dist(1-cor_Mat)



hr_m <- hclust(dist_hero, method = "single", members = NULL)
plot(hr_m, hang = -1)
rect.hclust(hr_m, k=2, border = "red")

hr_c <- hclust(dist_hero, method = "complete", members = NULL)
plot(hr_c, hang = -1)
rect.hclust(hr_c, k=4, border = "red")

#Question7----------------------------------------------------------------------
# single linkage
hr <- hclust(dist_hero, method = "single", members=NULL)
mycl <- cutree(hr, k=4)
mycl

plot(hr)
rect.hclust(hr, k=4, border="red")
hero_hc <- data.frame(hero_x_scaled, clusterID = as.factor(mycl))
hc_summary <- data.frame()

for (i in 1:(ncol(hero_hc)-1)){
  hc_summary = rbind(hc_summary, 
                     tapply(hero_hc[,i], hero_hc$clusterID, mean))
}

colnames(hc_summary) <- paste("cluster", c(1:4))
rownames(hc_summary) <- colnames(hero_x)
hc_summary

# Radar chart
library(plotrix)

par(mfrow = c(2,2))
for (i in 1:4){
  plot_title <- paste("Radar Chart for Cluster", i, sep=" ")
  radial.plot(hc_summary[,i], labels = rownames(hc_summary), 
              radial.lim=c(-2,3), rp.type = "p", main = plot_title, 
              line.col = "red", lwd = 3, show.grid.labels=1)
}

# complete linkage
hr <- hclust(dist_hero, method = "complete", members=NULL)
mycl <- cutree(hr, k=4)
mycl

plot(hr)
rect.hclust(hr, k=4, border="red")
hero_hc <- data.frame(hero_x_scaled, clusterID = as.factor(mycl))
hc_summary <- data.frame()

for (i in 1:(ncol(hero_hc)-1)){
  hc_summary = rbind(hc_summary, 
                     tapply(hero_hc[,i], hero_hc$clusterID, mean))
}

colnames(hc_summary) <- paste("cluster", c(1:4))
rownames(hc_summary) <- colnames(hero_x)
hc_summary

# Radar chart
library(plotrix)

par(mfrow = c(2,2))
for (i in 1:4){
  plot_title <- paste("Radar Chart for Cluster", i, sep=" ")
  radial.plot(hc_summary[,i], labels = rownames(hc_summary), 
              radial.lim=c(-10,10), rp.type = "p", main = plot_title, 
              line.col = "red", lwd = 3, show.grid.labels=1)
}


#Question8----------------------------------------------------------------------
hero_kmc <- kmeans(hero_x_scaled,4)

real_class <- hero_class
kmc_cluster <- hero_kmc$cluster
table(real_class, kmc_cluster)


hr1 <- hclust(dist_hero, method = "single", members=NULL)
hero_hlc_S <- cutree(hr1, k=4)
table(real_class, hero_hlc_S)

hr2 <- hclust(dist_hero, method = "complete", members=NULL)
hero_hlc_C <- cutree(hr2, k=4)
table(real_class, hero_hlc_C)





#Question9----------------------------------------------------------------------
install.packages("factoextra")
install.packages("dbscan")
library(factoextra)
library(dbscan)
library(tidyverse)

hero_scaled <- as.data.frame(scale(hero_x, center = TRUE, scale = TRUE))

options <- list(eps = c (0.5, 1, 2, 3, 4),
                minPts = c(10, 20, 30, 40, 50)) %>%
  cross_df()

for(i in 1:nrow(options)){
  DBSCAN_tmp <- dbscan(hero_scaled, eps = options$eps[i], MinPts = options$minPts[i])
  
  print(DBSCAN_tmp)
}

#Question10----------------------------------------------------------------------

