while read p; do
  cat > job_script.sh << EOF
#!/bin/bash
#SBATCH --job-name=poisson
#SBATCH --output=job_%j.out
#SBATCH --error=job_%j.err
#SBATCH --partition=CPU-all

source ~/.bashrc
$p
EOF

  sbatch job_script.sh
  sleep 0.5
done < "$1"


