#!/bin/sh

#Should be run from /usr/local/ycsb

logsfoldername="logs.$(date +%Y%m%d)"
mkdir ./"$logsfoldername"

for workload in a b c d e f
do
    echo "Testing fdbrecordlayer workload $workload"
    ./bin/ycsb load fdbrecordlayer -threads 8 -P "workloads/workload$workload" -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster > ./"$logsfoldername"/recdb."w$workload.load".csv
    ./bin/ycsb run fdbrecordlayer -threads 8 -P "workloads/workload$workload" -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster  > ./"$logsfoldername"/recdb."w$workload.run".csv
    
    echo "Testing foundationdb workload $workload"
    ./bin/ycsb load foundationdb -threads 8 -P "workloads/workload$workload" -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.load".csv
    ./bin/ycsb run foundationdb -threads 8 -P "workloads/workload$workload" -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.run".csv
done
