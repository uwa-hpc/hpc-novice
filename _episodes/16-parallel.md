---
title: "Running a parallel job"
teaching: 30
exercises: 30
questions:
- "How do we execute a task in parallel?"
objectives:
- "Understand how to run a parallel job on a cluster."
keypoints:
- "Parallelism is an important feature of HPC clusters."
- "MPI parallelism is a common case."
- "The queuing system facilitates executing parallel tasks."
---

We now have the tools we need to run a multi-processor job. This is a very
important aspect of HPC systems, as parallelism is one of the primary tools we
have to improve the performance of computational tasks.

Our simple hello world examples are help familiarize you with the SLURM directives.
So you can develop and test your job scripts and how to exploit the resources to 
get the best performance for you workflows. 

An outline the basic job script structure is:
* SBATCH directives - resource requests
* Define your environment by loading modules and setting variables
* Create unique directories for scratch (where to run) and group (where to store results) 
* Copy everything into scratch and run job
* Move results to group
* Clean UP 


## Running a Parallel Job on Multiple Compute Nodes

Create a submission file, requesting one task on a single node and enough
memory to prevent the job from running out of memory:

```
{{ site.remote.prompt }} nano hello_mpi_gnu.slurm
{{ site.remote.prompt }} cat hello_mpi_gnu.slurm
```
{: .language-bash}

{% include {{ site.snippets }}/parallel/hello_mpi-slurm.snip %}

Then submit your job. We will use the batch file to set the options,
rather than the command line.

```
{{ site.remote.prompt }} {{ site.sched.submit.name }} hello_mpi_gnu.slurm
```
{: .language-bash}

As before, use the status commands to check when your job runs.
Use `ls` to locate the output file, and examine it. Is it what you expected?

* How good is the value for &#960;?
* How much memory did it need?
* How long did the job take to run?

Modify the job script to increase both the number of samples and the amount
of memory requested (perhaps by a factor of 2, then by a factor of 10),
and resubmit the job each time.

* How good is the value for &#960;?
* How much memory did it need?
* How long did the job take to run?

Even with sufficient memory for necessary variables,
a script could require enormous amounts of time to calculate on a single CPU.
To reduce the amount of time required,
we need to modify the script to use multiple CPUs for the calculations.
In the largest problem scales,
we could use multiple CPUs in multiple compute nodes,
distributing the memory requirements across all the nodes used to
calculate the solution.

## Running the Parallel Job

We will run an example that uses the Message Passing Interface (MPI) for
parallelism -- this is a common tool on HPC systems.

> ## What is MPI?
>
> The Message Passing Interface is a set of tools which allow multiple parallel
> jobs to communicate with each other.
> Typically, a single executable is run multiple times, possibly on different
> machines, and the MPI tools are used to inform each instance of the
> executable about how many instances there are, which instance it is.
> MPI also provides tools to allow communication and coordination between
> instances.
> An MPI instance typically has its own copy of all the local variables.
{: .callout}

While MPI jobs can generally be run as stand-alone executables, in order for
them to run in parallel they must use an MPI *run-time system*, which is a
specific implementation of the MPI *standard*.
To do this, they should be started via a command such as `mpiexec` (or
`mpirun`, or `srun`, etc. depending on the MPI run-time you need to use),
which will ensure that the appropriate run-time support for parallelism is
included.

> ## MPI Runtime Arguments
>
> On their own, commands such as `mpiexec` can take many arguments specifying
> how many machines will participate in the execution,
> and you might need these if you would like to run an MPI program on your
> laptop (for example).
> In the context of a queuing system, however, it is frequently the case that
> we do not need to specify this information as the MPI run-time will have been
> configured to obtain it from the queuing system,
> by examining the environment variables set when the job is launched.
{: .callout}



Our purpose here is to exercise the parallel workflow of the cluster, not to
optimize the program to minimize its memory footprint.
Rather than push our local machines to the breaking point (or, worse, the login
node), let's give it to a cluster node with more resources.

Create a submission file, requesting one task on a single node:

```
{{ site.remote.prompt }} nano helloworld_gnu.slurm
{{ site.remote.prompt }} cat helloworld_gnu.slurm
```
{: .language-bash}

{% include {{ site.snippets }}/parallel/helloworld_gnu-slurm.snip %}

Then submit your job. We will use the batch file to set the options,
rather than the command line.

```
{{ site.remote.prompt }} {{ site.sched.submit.name }} helloworld_gnu.slurm
```
{: .language-bash}

As before, use the status commands to check when your job runs.
Use `ls` to locate the output file, and examine it.
Is it what you expected?

* How good is the value for &#960;?
* How much memory did it need?
* How much faster was this run than the serial run with more processors?

Modify the job script to increase both the number of samples and the amount
of memory requested (perhaps by a factor of 2, then by a factor of 10),
and resubmit the job each time.
You can also increase the number of CPUs.

* How good is the value for &#960;?
* How much memory did it need?
* How long did the job take to run?

## How Much Does MPI Improve Performance?

In theory, by dividing up the &#960; calculations among *n* MPI processes,
we should see run times reduce by a factor of *n*.
In practice, some time is required to start the additional MPI processes,
for the MPI processes to communicate and coordinate, and some types of
calculations may only be able to run effectively on a single CPU.

Additionally, if the MPI processes operate on different physical CPUs
in the computer, or across multiple compute nodes, additional time is
required for communication compared to all processes operating on a
single CPU.

[Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl's_law) is one way of
predicting improvements in execution time for a **fixed** parallel workload.
If a workload needs 20 hours to complete on a single core,
and one hour of that time is spent on tasks that cannot be parallelized,
only the remaining 19 hours could be parallelized.
Even if an infinite number of cores were used for the parallel parts of
the workload, the total run time cannot be less than one hour.

In practice, it's common to evaluate the parallelism of an MPI program by

* running the program across a range of CPU counts,
* recording the execution time on each run,
* comparing each execution time to the time when using a single CPU.

The speedup factor *S* is calculated as the single-CPU execution time divided
by the multi-CPU execution time.
For a laptop with 8 cores, the graph of speedup factor versus number of cores
used shows relatively consistent improvement when using 2, 4, or 8 cores, but
using additional cores shows a diminishing return.

{% include figure.html url="" caption="" max-width="50%"
   file="/fig/laptop-mpi_Speedup_factor.png"
   alt="MPI speedup factors on an 8-core laptop" %}

For a set of HPC nodes containing 28 cores each, the graph of speedup factor
versus number of cores shows consistent improvements up through three nodes
and 84 cores, but **worse** performance when adding a fourth node with an
additional 28 cores.
This is due to the amount of communication and coordination required among
the MPI processes requiring more time than is gained by reducing the amount
of work each MPI process has to complete. This communication overhead is not
included in Amdahl's Law.

{% include figure.html url="" caption="" max-width="50%"
   file="/fig/hpc-mpi_Speedup_factor.png"
   alt="MPI speedup factors on an 8-core laptop" %}

In practice, MPI speedup factors are influenced by:

* CPU design,
* the communication network between compute nodes,
* the MPI library implementations, and
* the details of the MPI program itself.

In an HPC environment, we try to reduce the execution time for all types of
jobs, and MPI is an extremely common way to combine dozens, hundreds, or
thousands of CPUs into solving a single problem. To learn more about 
parallelization, see the 
[parallel novice lesson](http://www.hpc-carpentry.org/hpc-parallel-novice/)

{% include links.md %}
