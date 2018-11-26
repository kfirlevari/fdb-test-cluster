#!/bin/sh

#Should be run from /usr/local/ycsb

for operationcount in 100000 # 1000000
do
    logsfoldername="logs.tx.op$operationcount.$(date +%Y.%h.%d)"
    mkdir ./"$logsfoldername"
    for tnum in 75 100 10 25 50
    do
        for usefixmultiopsize in true false
        do
            for multiopsize in 50 100 5 10 25
            do
                for readprop in 1 0.5 0.95
                do
                    updates=$( echo "1 - $readprop" | bc )
                    echo "Updates = 0$updates"
                    echo "Reads = $readprop"
                    echo "Testing fdbrecordlayer txworkload"
                    ./bin/ycsb load fdbrecordlayer -threads "$tnum" -P "workloads/txworkload" -p operationcount="$operationcount" -p readproportion="$readprop" -p updateproportion="0$updates" -p multiopmaxsize="$multiopsize" -p usefixmultiopsize="$usefixmultiopsize" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster > ./"$logsfoldername"/recdb."$usefixmultiopsize.t$tnum.op$multiopsize.r$readprop.load".csv
                    ./bin/ycsb run fdbrecordlayer -threads "$tnum" -P "workloads/txworkload" -p operationcount="$operationcount" -p readproportion="$readprop" -p updateproportion="0$updates" -p multiopmaxsize="$multiopsize" -p usefixmultiopsize="$usefixmultiopsize" -p fdbrecordlayer.usetimer=false -p fdbrecordlayer.debug=false -p fdbrecordlayer.clusterfile=/etc/foundationdb/fdb.cluster  > ./"$logsfoldername"/recdb."$usefixmultiopsize.t$tnum.op$multiopsize.r$readprop.run".csv
                    
                    echo "Testing foundationdb workload $workload"
                    ./bin/ycsb load foundationdb -threads "$tnum" -P "workloads/txworkload" -p operationcount="$operationcount" -p readproportion="$readprop" -p updateproportion="0$updates" -p multiopmaxsize="$multiopsize" -p usefixmultiopsize="$usefixmultiopsize" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."$usefixmultiopsize.t$tnum.op$multiopsize.r$readprop.load".csv
                    ./bin/ycsb run foundationdb -threads "$tnum" -P "workloads/txworkload" -p operationcount="$operationcount" -p readproportion="$readprop" -p updateproportion="0$updates" -p multiopmaxsize="$multiopsize" -p usefixmultiopsize="$usefixmultiopsize" -p foundationdb.debug=false -p foundationdb.clusterfile=/etc/foundationdb/fdb.cluster -p foundationdb.saveserialized=false > ./"$logsfoldername"/fdb."$usefixmultiopsize.t$tnum.op$multiopsize.r$readprop.run".csv
                done
            done
        done
    done
done
