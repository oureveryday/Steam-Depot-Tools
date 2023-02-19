import os
import vdf
import time
import shutil
import winreg
import sqlite3
import argparse
import requests
import traceback
from pathlib import Path
from multiprocessing.pool import ThreadPool
from multiprocessing.dummy import Pool, Lock

lock = Lock()

depotdownloader = "DepotDownloadermod.exe"
depotdownlaoderargs = "-max-servers 128 -max-downloads 256"

def get(sha, path):
    url_list = [f'https://cdn.jsdelivr.net/gh/{repo}@{sha}/{path}',
                f'https://ghproxy.com/https://raw.githubusercontent.com/{repo}/{sha}/{path}']
    retry = 3
    while True:
        for url in url_list:
            try:
                r = requests.get(url)
                if r.status_code == 200:
                    return r.content
            except requests.exceptions.ConnectionError:
                print(f'获取失败: {path}')
                retry -= 1
                if not retry:
                    print(f'超过最大重试次数: {path}')
                    raise

def downloader_add(appid,path: Path,outpath):
    depotid = path[0:path.find('_')]
    manifestid = path[path.find('_') + 1:path.find('.')]
    out = Path(os.path.join(outpath, f'{appid}.bat'))
    with out.open('a') as f:
        f.write(f'{depotdownloader} -app {appid} -depot {depotid} -manifest {manifestid} -manifestfile {path} -depotkeys {appid}.key {depotdownlaoderargs}\n')
    return True


def get_manifest(sha, path, output_path: Path, app_id=None):
    try:
        if path.endswith('.manifest'):
            save_path = Path(os.path.join(output_path,path))
            content = get(sha, path)
            with lock:
                print(f'清单下载成功: {path}')
            with save_path.open('wb') as f:
                f.write(content)
            downloader_add(app_id,path,output_path)

        elif path == 'config.vdf':
            content = get(sha, path)
            with lock:
                print(f'密钥下载成功: {path}')
            depots_config = vdf.loads(content.decode(encoding='utf-8'))

            if depotkey_add(
                    [(depot_id, '1', depots_config['depots'][depot_id]['DecryptionKey'])
                     for depot_id in depots_config['depots']],output_path,app_id):
                print('导入depotdownloader成功')
    except KeyboardInterrupt:
        raise
    except:
        traceback.print_exc()
        raise
    return True

def depotkey_add(depot_list,Outpath: Path,app_id):
    for depot_id, type_, depot_key in depot_list:
        if depot_key:
            depot_key = f'{depot_key}'
        out = Path(os.path.join(Outpath, f'{app_id}.key'))
        with out.open('a') as f:
            f.write(f'{depot_id};{depot_key}\n')
        
    return True


def get_script_path():
    return os.getcwd()


def main(app_id,path=get_script_path()):
    Outpath = Path(path)
    url = f'https://api.github.com/repos/{repo}/branches/{app_id}'
    r = requests.get(url)
    if 'commit' in r.json():
        sha = r.json()['commit']['sha']
        url = r.json()['commit']['commit']['tree']['url']
        r = requests.get(url)
        if 'tree' in r.json():
            result_list = []
            with Pool(32) as pool:
                pool: ThreadPool
                for i in r.json()['tree']:
                    result_list.append(pool.apply_async(get_manifest, (sha, i['path'], Outpath, app_id)))
                try:
                    while pool._state == 'RUN':
                        if all([result.ready() for result in result_list]):
                            break
                        time.sleep(0.1)
                except KeyboardInterrupt:
                    with lock:
                        pool.terminate()
                    raise
            if all([result.successful() for result in result_list]):
                print(f'导入成功: {app_id}')
                return True
    print(f'导入失败: {app_id}')
    return False

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--repo', default='wxy1343/ManifestAutoUpdate')
parser.add_argument('-a', '--app-id')
parser.add_argument('-p', '--output-path')
args = parser.parse_args()
repo = args.repo
if __name__ == '__main__':
    try:
        if args.output_path:
            if not os.path.exists(args.output_path):   
                os.makedirs(args.output_path) 
            main(args.app_id or input('appid: '),args.output_path)
        else:
            main(args.app_id or input('appid: '))
    except KeyboardInterrupt:
        exit()
    except:
        traceback.print_exc()
    if not args.app_id and not args.output_path:
        os.system('pause')
