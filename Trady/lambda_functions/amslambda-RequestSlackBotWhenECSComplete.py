import json
import boto3
import urllib.request


def lambda_handler(event, context):
    resource_arn = "-"
    service_name = "-"
    env = "-"
    try:

        print(f"request recieved:\n {event}")
        print(f"request recieved:\n {context}")

        if "resources" in event:  # for Eventbridge
            resource_arn = event["resources"][0]
        print(f"resource name is : {resource_arn}")

        service_name = resource_arn.split("/")[-1]
        print(f"service name is : {service_name}")

        send_post_request_to_slack_bot(service_name)

        return {"statusCode": 200, "body": "Alert ecs complete executed successfully."}
    except Exception as e:
        print(str(e))
        return {"statusCode": 500, "body": str(e)}


def send_post_request_to_slack_bot(service_name: str):
    try:
        color = "#d1180b"
        # if env == "prd":
        #     color = "#d1180b"
        # else:
        #     color = "#36a64f"

        send_data = {
            "text": "*컨테이너 배포가 완료되었습니다!:tada:*",
            "attachments": [
                {"fields": [{"title": f"서비스명 : {service_name}", "value": f"", "short": True}], "color": color}
            ],
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
