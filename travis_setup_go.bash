itravis_setup_go() {
  set -x  # Włączenie szczegółowego wypisywania poleceń

  local go_version="${TRAVIS_GO_VERSION:-${1}}"
  local go_import_path="${TRAVIS_GO_IMPORT_PATH:-${2}}"

  if [[ -z "${go_version}" ]]; then
    echo 'Missing TRAVIS_GO_VERSION' >&2
    return 86
  fi

  if [[ -z "${go_import_path}" ]]; then
    echo 'Missing TRAVIS_GO_IMPORT_PATH' >&2
    return 86
  fi

  # Ustawianie zmiennych środowiskowych i wypisywanie ich
  echo "Exporting GOPATH=${TRAVIS_HOME}/gopath"
  export GOPATH="${TRAVIS_HOME}/gopath"

  echo "Exporting PATH=${TRAVIS_HOME}/gopath/bin:${PATH}"
  export PATH="${TRAVIS_HOME}/gopath/bin:${PATH}"

  echo "Exporting GO111MODULE=${GO111MODULE}"
  export GO111MODULE="${GO111MODULE}"

  # Instalacja i konfiguracja Go
  echo "Instalowanie: go install \"golang.org/dl/go${go_version}@latest\""
  go install "golang.org/dl/go${go_version}@latest"

  echo "Pobieranie: \"go${go_version}\" download"
  "go${go_version}" download

  echo "Tworzenie dowiązania symbolicznego: sudo ln -s \"${TRAVIS_HOME}/gopath/bin/go${go_version}\" \"${TRAVIS_HOME}/gopath/bin/go\""
  sudo ln -s "${TRAVIS_HOME}/gopath/bin/go${go_version}" "${TRAVIS_HOME}/gopath/bin/go"

  echo "Ustalanie GOROOT:"
  export GOROOT=$("go${go_version}" env GOROOT)
  echo "GOROOT ustawione na: ${GOROOT}"

  echo "Aktualizacja PATH: export PATH=${GOROOT}/bin:${PATH}"
  export PATH=${GOROOT}/bin:${PATH}

  # Przygotowanie katalogu źródeł
  echo "Tworzenie katalogu dla importu: $(dirname "${GOPATH}/src/${go_import_path}")"
  mkdir -p "$(dirname "${GOPATH}/src/${go_import_path}")"

  echo "Tworzenie dowiązania symbolicznego źródeł: ln -s \"${TRAVIS_BUILD_DIR}\" \"$GOPATH/src/${go_import_path}\""
  ln -s "${TRAVIS_BUILD_DIR}" "$GOPATH/src/${go_import_path}"
}
