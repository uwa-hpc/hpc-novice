---
title: "Using R and RStudio"
teaching: 60
exercises: 10
questions:
- "How do we use R on Kaya?"
- "Can we run R interactively with RStudio on Kaya"
- "How do we install new packages"
objectives:
- "Understand how to run a R job on a cluster."
- "Configuring and Maintaining a R Librarys on Kaya."
- "Running RStudio Interactively on Kaya."
keypoints:
- "Maintaininr R Libraries on HPC clusters."
- "Using OnDemand"
- "Installing packaages on R"
---

One of the most popular applications for many researchers on 
Kaya is the statistical package R.

R is a programming language for statistical computing and data 
visualization. It has been widely adopted in the fields of data 
mining, bioinformatics, data analysis, and data science. The 
core R language is extended by a large number of software packages,
 which contain reusable code, documentation, and sample data.

This section is `not` about writing R scripts, it is about installing 
packages and running R scripts.

## Sample SLURM script for R

{% include {{ site.snippets }}/using-r/single_job.snip  %}

### Passing arguments to R scripts
Here is the simple example `R` script that takes command line arguemnts
and calls the function `logistic`. The `cl_arg.R` file takes three arguements
2 doubles and 1 integer.

{% include {{ site.snippets }}/using-r/cl_arg.snip  %}

Here is the `logistic.R` file

{% include {{ site.snippets }}/using-r/logistic.snip  %}

## Running an Array of jobs
SLURM has a feature which allows for managing/running hundreds or thousands of jobs from a single script.  
This is an great way to allow for you to do parametric studies or running a single analysis over many, many
input files.  So that you can get many jobs to run at the same time.


To use job arrays in a submission script, you need to use the SLURM directive `--array`. You need to add 
```
#SBATCH --array=x-y 
```
to the script, where x is the index of the first job and y is the index of the last one.
The task id range specified in the option argument may be:

Submit a job array with comma separated index values: 
```
#SBATCH --array=2,4,6 
```
## (2, 4, 6) 3 jobs

Submit a job array with index values form x-y: 
```
#SBATCH --array=1-15 
```
## (1, 2, 3, …, 15) 15 jobs

Submit a job array with index values between 10 and 20 with a step size of 2 : 
```
#SBATCH --array=10-20:2 
```
## (10, 12, 14, … 20) 6 jobs
To be nice on the system if you are wanting to run a LARGE number of tasks add a modifier to the 
SLURM directive show in the following example.

## SLURM Job Array Example script

{% include {{ site.snippets }}/using-r/array_job.snip  %}

### Job Array tips and tricks
```
#SBATCH --array=1:100%10 ### %10 limits the number of jobs running simultaneously to 10 jobs
```
Using array is not a big issue if you are using a single core and can pack jobs to one node.  

It is potentially a *bigger* issue if you want to run a job for example that takes 
all the memory on a node so only one job is running on the node.

Pay attention to the differences in the SBATCH directives in the two jobs scripts
```
--output=Rarray_%A_%a.out 
```
and
``` 
--output=Rscript_%A.out
```

The `%A` is the SLURM_ARRAY_JOB_ID for arrays and 
SLURM_JOBID `%a` is the SLURM_ARRAY_TASK_ID 

To check jobs in queue
```
squeue -u $USER     <- note $USER is your username 
```
## How to cancel jobs
To kill a job the command is: 
```
scancel <JOBID>
```
JOBID is the first column of numbers shown in squeue -u $USER

for arrays
```
scancel <JOBID>
```
for a single task
```
scancel <JOBID>_<TASK_ID>
```
for a subset of tasks
```
scancel <JOBID>_[<TASK_ID>_<TASK_ID>]  <- note square brackets!!!
```

{% include links.md %}
