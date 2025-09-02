---
title: "Using R and RStudio"
teaching: 60
exercises: 10
questions:
- "How do we use R on Kaya?"
- "SLURM scripting for a single R job and arrays of R jobs"
- "How do we install new packages"
objectives:
- "Understand how to run a R job on a cluster."
- "Configuring and Maintaining a R Librarys on Kaya."
keypoints:
- "Maintaininr R Libraries on HPC clusters."
- "Installing packaages on R"
---

One of the most popular applications for many researchers on 
Kaya is the statistical package R.

R is a programming language for statistical computing and data 
visualization. It has been widely adopted in the fields of data 
mining, bioinformatics, data analysis, and data science. The 
core R language is extended by a large number of software packages,
 which contain reusable code, documentation, and sample data.

### This episode is `NOT` about writing R scripts, it is about running R scripts and maintaining R.

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
## R Package Library Managment 

On Kaya we do support the base R statistical application. Howeve we do not support
centrally additional librarys and package as it is too complicated to do centrally.
What we do allow is for researchers on Kaya to maintain local R libraries.  To this end 
we have a set of tools *scripts* we do support and can help researchers use.

### R Environment 

When you run the command `R` it searches for additional R libaries that are included in the R environment.
Most likey when you have run `R` in the past the R libraries are installed in the default location which is 
where the base `R` is installed.  On Kaya this is in 
```
\uwahpc\rocky9\apps\gcc\14.3.0\r\4.4.2 
```
if you inspect this using **ls -al** you will see 
```
[cbording@kaya01 ~]$ ls -al /uwahpc/rocky9/apps/gcc/14.3.0/r/4.4.2 
total 5
drwxr-xr-x 5 maali maali 4096 Jun  3 09:41 .
drwxr-xr-x 4 maali maali 4096 Jun  3 09:34 ..
drwxr-xr-x 2 maali maali 4096 Jun  3 09:41 bin
drwxr-xr-x 4 maali maali 4096 Jun  3 09:41 lib64
drwxr-xr-x 3 maali maali 4096 Jun  3 09:41 share
```
Everything is that director is `owned` by **maali**. This means you can't write to the `lib64` directory.
However you can change the search path because `R` searchs in your `$HOME` directory before it looks in the
default location, it will add the value of `R_LIBS_USER` to the search path for `R`.

In your `$HOME` directory you can create a file **.Renviron** with `R_LIBS_USER` defined.

```
 # set the R_LIBS_USER path
 R_LIBS_USER=${R_LIBRARY} 
```

### Defined and creating a local R library.

In your home directory for a hidden file ***.Renviron*** in which you can 
define R environment variables.  The one we will focus on is,
```
R_LIBS_USER=<path to local R library>
```
Where to create a local `R library`, on Kaya? This should be in your *$MYGROUP* as your *$HOME* 
directory is has a hard quota of *20GB* so it is too small to have the library there.

Here is a example of installing two package to a locally defined `R library`.

{% include {{ site.snippets }}/using-r/seurat.snip  %}

Here is an example for installing R packages from a github repository.

{% include {{ site.snippets }}/using-r/github_pkg.snip  %}


{% include links.md %}
