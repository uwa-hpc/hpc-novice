```
R_LIBRARY="/group/<project_id>/$USER/Rlibrary/4.4.1"
options(Ncpus = 12)
local({r = getOption("repos");r["CRAN"]="https://mirror.aarnet.edu.au/pub/CRAN/"; options(repos=r)})
setRepositories(graphics=F,ind=1:6)
packs=c("gridExtra","Seurat")
install.packages(packs,lib="/group/<project_id>/$USER/Rlibrary/4.4.1")
```
{: .language-bash}