function _directory_changed_hook() {
  # 기존에 로딩되어있는 환경파일이 있다면 등록해제 합니다.
  _unload_current_dir_env

  # 만약 도착한 경로에도 환경파일이 있다면 등록합니다.
  _load_current_dir_env
}
