#!/usr/bin/env python3
"""
Lambda 함수들을 ZIP 파일로 압축하는 스크립트
"""
import os
import zipfile
import shutil

def create_lambda_zip(function_name, source_dir, output_dir):
    """Lambda 함수를 ZIP 파일로 압축"""
    
    # 출력 디렉토리 생성
    os.makedirs(output_dir, exist_ok=True)
    
    # ZIP 파일 경로
    zip_path = os.path.join(output_dir, f"{function_name}.zip")
    
    # 기존 ZIP 파일이 있으면 삭제
    if os.path.exists(zip_path):
        os.remove(zip_path)
    
    print(f"Creating ZIP for {function_name}...")
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # 소스 디렉토리의 모든 파일을 ZIP에 추가
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                file_path = os.path.join(root, file)
                # ZIP 내부 경로 (루트 디렉토리 제거)
                arcname = os.path.relpath(file_path, source_dir)
                zipf.write(file_path, arcname)
                print(f"  Added: {arcname}")
    
    print(f"✅ Created: {zip_path}")
    return zip_path

def main():
    """메인 함수"""
    print("🚀 Lambda 함수 ZIP 파일 생성 시작...")
    
    # 현재 디렉토리
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Lambda 함수들
    functions = [
        {
            "name": "request_slack_bot",
            "source": os.path.join(current_dir, "lambda_functions", "request_slack_bot"),
            "output": os.path.join(current_dir, "lambda_functions")
        },
        {
            "name": "allocate_public_ip", 
            "source": os.path.join(current_dir, "lambda_functions", "allocate_public_ip"),
            "output": os.path.join(current_dir, "lambda_functions")
        }
    ]
    
    # 각 함수에 대해 ZIP 생성
    for func in functions:
        if os.path.exists(func["source"]):
            create_lambda_zip(func["name"], func["source"], func["output"])
        else:
            print(f"❌ Source directory not found: {func['source']}")
    
    print("\n🎉 Lambda ZIP 파일 생성 완료!")
    print("\n📁 생성된 파일들:")
    for func in functions:
        zip_path = os.path.join(func["output"], f"{func['name']}.zip")
        if os.path.exists(zip_path):
            size = os.path.getsize(zip_path)
            print(f"  - {zip_path} ({size} bytes)")

if __name__ == "__main__":
    main() 