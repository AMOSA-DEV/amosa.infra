import json
import boto3
import os

def lambda_handler(event, context):
    """
    ECS 작업 완료 시 Slack 봇에 요청을 보내는 Lambda 함수
    """
    try:
        # 이벤트 로깅
        print(f"Event received: {json.dumps(event)}")
        
        # Slack 웹훅 URL (환경변수에서 가져오기)
        slack_webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
        
        if not slack_webhook_url:
            return {
                'statusCode': 500,
                'body': 'SLACK_WEBHOOK_URL environment variable not set'
            }
        
        # Slack 메시지 구성
        message = {
            "text": "ECS 작업이 완료되었습니다! 🎉",
            "attachments": [
                {
                    "color": "good",
                    "fields": [
                        {
                            "title": "작업 상태",
                            "value": "완료",
                            "short": True
                        },
                        {
                            "title": "실행 시간",
                            "value": context.get_remaining_time_in_millis(),
                            "short": True
                        }
                    ]
                }
            ]
        }
        
        # Slack으로 메시지 전송
        import urllib3
        http = urllib3.PoolManager()
        
        response = http.request(
            'POST',
            slack_webhook_url,
            body=json.dumps(message),
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status == 200:
            return {
                'statusCode': 200,
                'body': 'Slack notification sent successfully'
            }
        else:
            return {
                'statusCode': response.status,
                'body': f'Failed to send Slack notification: {response.data.decode()}'
            }
            
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Internal server error: {str(e)}'
        } 