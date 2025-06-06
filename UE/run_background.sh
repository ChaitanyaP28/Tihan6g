if ! command -v realpath &>/dev/null; then
    echo "Package \"coreutils\" not found, installing..."
    sudo apt-get install -y coreutils
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR"


#MyMod
source ../MyMod.conf
echo "NUM_UES is $NUM_UES"

#NUM_UES=4
if [ "$#" -eq 1 ]; then
    NUM_UES=$1
fi

if ! [[ $NUM_UES =~ ^[0-9]+$ ]]; then
    echo "Error: Number of UEs must be a number."
    exit 1
fi

if [ $NUM_UES -lt 1 ]; then
    echo "Error: Number of UEs must be greater than or equal to 1."
    exit 1
fi

for (( UE_NUMBER=1; UE_NUMBER<=NUM_UES; UE_NUMBER++ )); do
    if [ ! -f "configs/ue${UE_NUMBER}.conf" ]; then
        echo "Configuration was not found for OAI UE $UE_NUMBER. Please run ./generate_configurations.sh first."
        exit 1
    fi

    echo "Starting User Equipment $UE_NUMBER in background..."
    mkdir -p logs
    >logs/ue${UE_NUMBER}_stdout.txt

    sudo setsid bash -c "stdbuf -oL -eL \"$SCRIPT_DIR/run.sh\" $UE_NUMBER > logs/ue${UE_NUMBER}_stdout.txt 2>&1" </dev/null &

    ATTEMPT=0
    while $(./is_running.sh $UE_NUMBER | grep -q "NOT_RUNNING"); do
        sleep 0.5
        ATTEMPT=$((ATTEMPT + 1))
        if [ $ATTEMPT -ge 120 ]; then
            echo "UE $UE_NUMBER did not start after 60 seconds, exiting..."
            exit 1
        fi
    done

    echo "UE $UE_NUMBER is running."
done

./is_running.sh
