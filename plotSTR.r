
library(reshape)
library(stringr)
library(ggplot2)

#function for extracting the cluster Probs, requires STR infile because STRUCTURE likes to chop off the ends of your sample names so I have to use your original file to get your original names
read.STR<-function(STR.in,STR.out){
#read in data
str<-read.table(STR.in,skip=1)	
str.out<-readLines(STR.out)
#the next part parses the structure outfile and grabs the q score part
q.tab.id <- grep("Inferred ancestry of individuals:",str.out,
						 value=FALSE)
num.ind <- grep("Run parameters:",str.out,
						 value=FALSE)+1
num.ind<-str.out[num.ind]	 				 
num.ind<-as.numeric(str_extract_all(num.ind,"[0-9.A-Za-z_]+")[[1]][1])
q.end.id<-1+num.ind+q.tab.id		
q.tab<-str.out[(q.tab.id+2):q.end.id]
qs<-t(sapply(str_extract_all(q.tab,"[0-9.A-Za-z_]+"),as.character))
qs<-qs[,c(2,5:dim(qs)[2])]
qs<-data.frame(qs)
nclust<- dim(qs)[2]-1
#this part replaces the names with your original names
 qs[,1]<-str[,1]
write.csv(qs,paste("k",nclust,".csv",sep=""),row.names=F)
}



#this function plots the structure plot, it takes the result of read.STR, it will also optionaly take a file to reorder the plot, if you dont already have one just reorder your outfile from above and save it
plotSTR<-function(Cluster.csv,order=Cluster.csv){
#I turn off warnings because it will tell you about duplicated factors below 
oldw <- getOption("warn")
options(warn = -1)
#read data
data<-read.csv(Cluster.csv)
order<-read.csv(order)
nclust<-dim(data)[2]-1
#relabel the columns
labs<-c("Sample",paste("Cluster",seq(1:nclust),sep=""))
names(data)<-labs
#reorder, this doesnt do anything if you dont supply an order file
data<-data[match(order[,1],data$Sample),]
#remove duplicates, you shouldnt have duplicates anyway
data<-data[!duplicated(data$Sample),]
#I melt here to make the plotting easy
mdata<-melt(data)
names(mdata)<-c("Sample","Species","Probability")
mdata$Sample<-factor(mdata$Sample,levels=mdata$Sample)

#Manully set color for each cluster.
#Delete X-axis texts.
#Delete X/Y-axis names. 
p<-ggplot(mdata,aes(x=Sample,y=Probability,fill=Species)) + geom_bar(stat="identity",position="stack") + scale_fill_manual(values=c("Cluster1"="navy", "Cluster2"="yellow", "Cluster3"="#7F405F", "Cluster4"="lightpink", "Cluster5"="lightgray")) +
theme_classic() + 
theme(axis.line=element_blank(),axis.ticks.x=element_blank(),axis.text.x=element_blank(),axis.text.y=element_text(size=30, face="bold",colour = "black"),legend.position="none") +
theme(axis.ticks.y = element_line(size=1, color="black"), axis.ticks.length=unit(8,'mm') ) +
scale_y_continuous(breaks=c(0.0,0.2,0.4,0.6,0.8,1.0),labels = c("0.00","0.20","0.40","0.60","0.80","1.00"))+
annotate(x=0, xend=0, y=0, yend=1, colour="black", lwd=2, geom="segment")+
labs(x="",y="")
print(p)
ggsave(paste("k",nclust,"STRplot.pdf",sep=""),width = 44.8, height = 8.4)
options(warn = oldw)
}
