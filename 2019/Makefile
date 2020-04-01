.PHONY : build-2019 push-2019

IMG_NAME := texlive-docker

build-2019: 2019/Dockerfile
	@docker build \
	--build-arg VCS_URL=$(VCS_URL) \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--tag blueogive/${IMG_NAME}:2019 \
	--tag blueogive/${IMG_NAME}:$(TAG_DATE) \
	--tag blueogive/${IMG_NAME}:latest 2019/

push-2019 : build-2019
	@docker push blueogive/${IMG_NAME}:2019
	@docker push blueogive/${IMG_NAME}:latest
	@docker push blueogive/${IMG_NAME}:$(TAG_DATE)
