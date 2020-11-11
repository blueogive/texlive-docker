.PHONY : docker-prune docker-check build push

VCS_URL := $(shell git remote get-url --push gh)
VCS_REF := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
TAG_DATE := $(shell date -u +"%Y%m%d")
TL_VERSION := $(shell date -u +"%Y")

docker-prune :
	@echo Pruning Docker images/containers/networks not in use
	docker system prune

docker-check :
	@echo Computing reclaimable space consumed by Docker artifacts
	docker system df

build: Dockerfile
	@docker build \
	--build-arg TL_VERSION=$(TL_VERSION) \
	--build-arg VCS_URL=$(VCS_URL) \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--tag blueogive/texlive:$(TL_VERSION) \
	--tag blueogive/texlive:$(TAG_DATE) \
	--tag blueogive/texlive:latest .

push : build
	@docker push blueogive/texlive:$(TL_VERSION)
	@docker push blueogive/texlive:latest
	@docker push blueogive/texlive:$(TAG_DATE)
