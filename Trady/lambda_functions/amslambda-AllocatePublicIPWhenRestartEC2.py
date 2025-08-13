import json
import boto3
import urllib.request


def lambda_handler(event, context):
    allocation_id = "eipalloc-03784fbc4e35d0c14"  # 탄력적 IP의 할당 ID (allocation ID)

    ec2 = boto3.client("ec2")

    try:
        # Describe the instance to check its state
        response = ec2.describe_instances()
        reservations = response["Reservations"]
        if not reservations:
            send_post_request_to_slack_bot("error", "No EC2 instances found.")
            return

        # 첫 번째 인스턴스를 가져옴 (우리는 당분간 1개만 사용하므로)
        instance = reservations[0]["Instances"][0]
        instance_id = instance["InstanceId"]
        instance_state = instance["State"]["Name"]

        if instance_state == "running":
            # 기존의 탄력적 IP가 연결되지 않은 경우 연결
            network_interface_id = instance["NetworkInterfaces"][0]["NetworkInterfaceId"]
            print(f"Instance {instance_id} is running. Reassociating Elastic IP.")

            # 탄력적 IP를 네트워크 인터페이스에 연결
            ec2.associate_address(AllocationId=allocation_id, NetworkInterfaceId=network_interface_id)
            send_post_request_to_slack_bot(
                "info", f"Elastic IP {allocation_id} associated with instance {instance_id}."
            )
        else:
            send_post_request_to_slack_bot(
                "error", f"Instance {instance_id} is not in 'running' state. Current state: {instance_state}"
            )

    except Exception as e:
        send_post_request_to_slack_bot("error", f"Error: {str(e)}")
        raise e


def send_post_request_to_slack_bot(type: str, message: str):
    print(message)
    try:
        color = "#d1180b"
        if type == "error":
            color = "#d1180b"
        else:
            color = "#36a64f"

        send_data = {
            "text": "*EC2가 재시작되어 public IP를 재할당 시도했습니다.*",
            "attachments": [{"fields": [{"title": f"{message}", "value": f"", "short": True}], "color": color}],
        }
        send_text = json.dumps(send_data)
        request = urllib.request.Request(
            "https://hooks.slack.com/services/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",
            data=send_text.encode("utf-8"),
        )
        with urllib.request.urlopen(request) as response:
            slack_message = response.read()

    except Exception as e:
        print(str(e))
        raise str(e)
