import json
import boto3
import os

def lambda_handler(event, context):
    """
    EC2 재시작 시 Public IP를 할당하는 Lambda 함수
    """
    try:
        # 이벤트 로깅
        print(f"Event received: {json.dumps(event)}")
        
        # EC2 클라이언트 생성
        ec2_client = boto3.client('ec2')
        
        # 이벤트에서 EC2 인스턴스 ID 추출
        instance_id = None
        if 'detail' in event and 'instance-id' in event['detail']:
            instance_id = event['detail']['instance-id']
        elif 'instance-id' in event:
            instance_id = event['instance-id']
        
        if not instance_id:
            return {
                'statusCode': 400,
                'body': 'Instance ID not found in event'
            }
        
        print(f"Processing instance: {instance_id}")
        
        # EC2 인스턴스 정보 조회
        response = ec2_client.describe_instances(
            InstanceIds=[instance_id]
        )
        
        if not response['Reservations']:
            return {
                'statusCode': 404,
                'body': f'Instance {instance_id} not found'
            }
        
        instance = response['Reservations'][0]['Instances'][0]
        current_state = instance['State']['Name']
        
        # 인스턴스가 실행 중인지 확인
        if current_state != 'running':
            return {
                'statusCode': 200,
                'body': f'Instance {instance_id} is not running (state: {current_state})'
            }
        
        # Public IP 할당 여부 확인
        if 'PublicIpAddress' in instance and instance['PublicIpAddress']:
            print(f"Instance {instance_id} already has public IP: {instance['PublicIpAddress']}")
            return {
                'statusCode': 200,
                'body': f'Instance {instance_id} already has public IP'
            }
        
        # Elastic IP 할당
        print(f"Allocating Elastic IP for instance {instance_id}")
        eip_response = ec2_client.allocate_address(
            Domain='vpc'
        )
        
        eip_allocation_id = eip_response['AllocationId']
        eip_public_ip = eip_response['PublicIp']
        
        # Elastic IP를 인스턴스에 연결
        ec2_client.associate_address(
            AllocationId=eip_allocation_id,
            InstanceId=instance_id
        )
        
        print(f"Successfully allocated and associated EIP {eip_public_ip} to instance {instance_id}")
        
        return {
            'statusCode': 200,
            'body': {
                'message': 'Public IP allocated successfully',
                'instance_id': instance_id,
                'elastic_ip': eip_public_ip,
                'allocation_id': eip_allocation_id
            }
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Internal server error: {str(e)}'
        } 