# This script loads trial information and renames all betas to set up for RSA
# The format for betas is:
#   1-12 are Encoding trials 13-24 (second rep) from the task
#     1-3: RP related
#     4-6: RS related
#     7-9: RP practiced
#     10-12: RS practiced
#   13-30 are Practice trials
#     25-27: RP cycle 1
#     28-30: RP cycle 2
#     31-33: RP cycle 3
#     34-36: RS cycle 1
#     37-39: RS cycle 2
#     40-42: RS cycle 3

analysisDir <- '~/MatlabWork/Retriev01/Analysis/LSS/'

subs <- c(02, 04, 05, 06, 07, 08, 10, 11, 12, 13, 15, 16, 17, 18, 
          19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 33)
stem <- 'retriev01_S'

oldBetaDir <- 'betas_nii'
newBetaDir <- 'search_betas'

trialFileDir <- '~/Box Sync/Experiments/RIFA/fMRIStudy/Behav/'
trialFileEnd <- '_RSA_clean.csv'


for (sub in 1:length(subs)) {
  setwd(paste(analysisDir, stem, formatC(subs[sub], width = 2, format = "d", flag = "0"), #to add 0 to all S# < 10
              '/', sep = ""))
  
  #Create new beta dir
  dir.create(newBetaDir)
  
  #Copy relevant betas to new dir
  allOldFiles <- list.files(oldBetaDir, full.names = T)
  file.copy(from = allOldFiles, to = newBetaDir)
  
  #Load in csv with trial number and type
  currTrialInfo <- read_csv(paste(trialFileDir, stem, 
                                  formatC(subs[sub], width = 2, format = "d", flag = "0"),
                                  trialFileEnd, sep = ""))
  
  #Cycle through the 10 runs
  for (runNum in 1:10) {
    currRunInfo <-  filter(currTrialInfo, run == runNum)
    
    #Cycle through the two types of practice
    for (type in 1:2) {
      if (type == 1) {
        relLab <- "NP"
        pracLab <- "RP"
      }
      else {
        relLab <- "NS"
        pracLab <- "RS"
      }    
      
      #find and rename the trials 
      for (pracType in 1:2) {
        ifelse(pracType == 1, currLab <- relLab, currLab <- pracLab)
        
        #find and rename encoding trials (2nd encoding only by filtering 12 >< 25)
          #cycles through twice; first for related items (NP, NS), second for practice items (RP, RS)
        currEncodeInfo <- filter(currRunInfo, trial_type == currLab, trial_num > 12, trial_num < 25)
        for (trialNum in 1:3) {
          oldBetaName <- paste('Sess0', formatC(runNum, width = 2, format = "d", flag = "0"), #to pad run number with zeros if < 10
                '_Encoding_0', currEncodeInfo$trial_num[trialNum], '.nii',
                sep = "")
          newBetaName <- paste('Run', runNum, '_encoding_', currLab, trialNum, '.nii', sep = "")
          file.rename(from = file.path(newBetaDir, oldBetaName), to = file.path(newBetaDir, newBetaName))
        }
        #find and rename the practice trials (filtering > 24)
        if (pracType == 2) {
          currPracInfo <- filter(currRunInfo, trial_type == currLab, trial_num > 24) %>%
            mutate(prac_order = row_number()) %>%
            arrange(cycle, encode_num)
          for(trialNum in 1:9) {
            oldBetaName <- paste('Sess0', formatC(runNum, width = 2, format = "d", flag = "0"), #to pad run number with zeros if < 10
                                 '_Prac_', currLab, '_00', currPracInfo$prac_order[trialNum], '.nii',
                                 sep = "")
            newBetaName <- paste('Run', runNum, '_prac_', currLab, trialNum, '_cyc', 
                                 currPracInfo$cycle[trialNum], '.nii', sep = "")
            file.rename(from = file.path(newBetaDir, oldBetaName), to = file.path(newBetaDir, newBetaName))
          }
        }
      }
    }
  }
}
