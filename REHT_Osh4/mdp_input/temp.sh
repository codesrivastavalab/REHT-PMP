#!/bin/bash

# number of replicas
nrep=15
# "effective" temperature range
tmin=303.15
tmax=333.15

# build geometric progression
list=$(
awk -v n=$nrep \
    -v tmin=$tmin \
    -v tmax=$tmax \
  'BEGIN{for(i=0;i<n;i++){
    t=tmin*exp(i*log(tmax/tmin)/(n-1));
    printf(t); if(i<n-1)printf(",");
  }
}'
)
echo $list

i=0
for temp in ${list//,/ }
do
    sed 's/XXX/'$temp'/g' md.mdp > md$i.mdp
    i=$(($i+1));
done

