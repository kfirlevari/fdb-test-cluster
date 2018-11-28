#!/bin/sh

#Should be run from /usr/local/ycsb

recordcount=10000
operationcount=1000000
logsfoldername="logs.op$operationcount.$(date +%Y.%h.%d)"
mkdir ./"$logsfoldername"

for workload in a b c d f
do
    for tnum in 50
    do
        echo "Testing fdbrecordlayer workload $workload"
        ./bin/ycsb load fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster > ./"$logsfoldername"/recdb."w$workload.t$tnum.load".csv
        ./bin/ycsb run fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordloayer.clusterfile=/etc/foundationdb/fdb.cluster  > ./"$logsfoldername"/recdb."w$workload.t$tnum.run".csv
        
        echo "Testing foundationdb workload $workload"
        ./bin/ycsb load foundationdb -threads "$tnum" -P "workloads/workload$workload" -p recordcount="$recordcount" -p operationcount="$operationcount" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.t$tnum.load".csv
        ./bin/ycsb run foundationdb -threads  "$tnum" -P "workloads/workload$workload" -p recordcount="$recordcount" -p operationcount="$operationcount" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.t$tnum.run".csv
    done
done

workload=e
recordcount=1000
operationcount=10000
for tnum in 50
do
    echo "Testing fdbrecordlayer workload $workload"
    
    ./bin/ycsb load fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p useQueryForScan="true" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster > ./"$logsfoldername"/recdb."w$workload.t$tnum.load".csv
    ./bin/ycsb run fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p useQueryForScan="true" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordloayer.clusterfile=/etc/foundationdb/fdb.cluster  > ./"$logsfoldername"/recdb."w$workload.t$tnum.query.run".csv
    
    ./bin/ycsb load fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p useQueryForScan="false" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster > ./"$logsfoldername"/recdb."w$workload.t$tnum.load".csv
    ./bin/ycsb run fdbrecordlayer -threads  "$tnum" -P "workloads/workload$workload" -p useQueryForScan="false" -p recordcount="$recordcount" -p operationcount="$operationcount" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordloayer.clusterfile=/etc/foundationdb/fdb.cluster  > ./"$logsfoldername"/recdb."w$workload.t$tnum.scan.run".csv
    
    echo "Testing foundationdb workload $workload"
    ./bin/ycsb load foundationdb -threads "$tnum" -P "workloads/workload$workload" -p operationcount="$operationcount" -p recordcount="$recordcount" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.t$tnum.load".csv
    ./bin/ycsb run foundationdb -threads  "$tnum" -P "workloads/workload$workload" -p operationcount="$operationcount" -p recordcount="$recordcount" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."w$workload.t$tnum.run".csv
done
