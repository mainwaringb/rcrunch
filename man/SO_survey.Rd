% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SO-survey.R
\docType{data}
\name{SO_survey}
\alias{SO_survey}
\title{R users who responded to the 2017 Stack Overflow developer survey}
\format{
A data frame with 1634 rows and 25 variables.
\describe{
\item{Respondent}{Respondent ID number}
\item{Professional}{Which of the following best describes you?}
\item{Country}{In which country do you currently live?}
\item{CompanySize}{In terms of the number of employees, how large is the company or organization you work for?}
\item{CareerSatisfaction}{Career satisfaction rating}
\item{JobSatisfaction}{Job satisfaction rating}
\item{ImportantHiringAlgorithms}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Knowledge of algorithms and data structures}
\item{ImportantHiringTechExp}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Experience with specific tools (libraries, frameworks, etc.) used by the employer}
\item{ImportantHiringCommunication}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Communication skills}
\item{ImportantHiringOpenSource}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Contributions to open source projects}
\item{ImportantHiringPMExp}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Experience with specific project management tools & techniques}
\item{ImportantHiringCompanies}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Previous companies worked at}
\item{ImportantHiringTitles}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Previous job titles held}
\item{ImportantHiringEducation}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Educational credentials (e.g. schools attended, specific field of study, grades earned)}
\item{ImportantHiringRep}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Stack Overflow reputation}
\item{ImportantHiringGettingThingsDone}{Congratulations! You've just been put in charge of technical recruiting at Globex, a multinational high- tech firm. This job comes with a corner office, and you have an experienced staff of recruiters at your disposal. They want to know what they should prioritize when recruiting software developers. How important should each of the following be in Globex's hiring process? Track record of getting things done}
\item{Gender}{Which of the following do you currently identify as?}
\item{Race}{Which of the following do you identify as?}
\item{Salary}{What is your current annual base salary, before taxes, and excluding bonuses, grants, or other compensation?}
\item{ExpectedSalary}{You said before that you are currently learning how to program. When you have completed your studies, what annual salary do you expect to earn in your first job after graduation?}
\item{TabsSpaces}{Tabs or spaces?}
\item{WantWorkLanguage}{Which of the following languages have you done extensive development work in over the past year, and which do you want to work in over the next year?}
\item{HaveWorkedLanguage}{Which of the following languages have you done extensive development work in over the past year, and which do you want to work in over the next year?}
}
}
\source{
\url{https://insights.stackoverflow.com/survey/}
}
\usage{
SO_survey
}
\description{
A slightly modified version of the 2017 Stack Overflow developer survey. The
dataset is filtered to only include respondents who have used R before, and
to include illustrative variable types.
}
\keyword{datasets}
