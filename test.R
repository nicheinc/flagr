source("R/flagr.R")

flagr <- flagr()

echo <- flagr$add_flag(
  name="echo",
  type="character",
  description="Value to echo",
  default="echo...echo...echo"
)

flagr$parse()

cat(paste0(echo, "\n"))
