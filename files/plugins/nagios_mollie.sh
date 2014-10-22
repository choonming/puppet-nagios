#!/bin/sh
# Username and password associated with Mollie  account
# Modify these values to match your account credentials if you don't want to
# specify them as command line arguments.
username=
password=


# Show usage if necessary
if [ $# -eq 0 ]; then
    echo "Usage: $0 -n [number] -m [message] -u [username] -p [password] -g [gateway]"
    echo ""
    echo "[number]   = SMS number to send message to"
    echo "[message]  = Text of message you want to send"
	echo "[gateway]  = Define the gateway you want to sent trought"
    echo "[sender]   = Sender"
    echo "[username] = Username assocated with Mollie  account"
    echo "[password] = Password assocated with Mollie account"
    echo "               Both the username and password options are optional and"
    echo "               override the account credentials defined in this script."
    echo ""
    exit 1;
fi


# Get command line arguments
while [ "$1" != "" ] ; do
    case $1
    in
	-n)
	    # Get the SMS number that we should send message to
	    number=$2;
	    shift 2;
	    ;;
	-m)
	    # Get the message we should send
	    message=$2;
	    shift 2;
	    ;;
	-s)
	    # Get the sender to show in the SMS
	    sender=$2;
	    shift 2;
	    ;;
	-u)
	    # Get the username
	    username=$2;
	    shift 2;
	    ;;
	-p)
	    # Get the password
	    password=$2;
	    shift 2;
	    ;;
	-g)
		# Get the gateway
		gateway=$2;
		shift 2;
		;;
	*)
	    echo "Unknown option: $1"
	    exit 1;
	    ;;
    esac
done


# We haven't sent the message yet
message_sent_ok=0;

# Try to send an HTTP POST message (try all servers until successful)
for server in www ; do

    RESPONSE=`curl -v -d username=$username -d password=$password -d gateway=$gateway -d originator=$sender -d recipients=$number -d message="$message" https://api.messagebird.com/xml/sms`

    # Curl was able to post okay...
    if [ "$?" -eq "0" ]; then

	RETURN=`echo $RESPONSE |sed 's!.*<resultcode>\(.*\)</resultcode>.*!\1!'`
	
	ERRORMESSAGE=`echo $RESPONSE |sed 's!.*<resultmessage>\(.*\)</resultmessage>.*!\1!'`
	
	# Test the response from the Mollie server
	case $RETURN
	in
	    10)
		# Message was queued ok
		mesage_sent_ok=1;
		echo "Message posted OK to HTTP gateway $gateway"
		exit 0;
		;;
	    *)
		# Some kind of fatal error occurred
		echo $ERRORMESSAGE
		exit 1;
		;;
	esac

    fi

done
