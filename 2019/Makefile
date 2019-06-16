.PHONY : build-2019 push-2019

build-2019: 2019/Dockerfile
	@docker build \
	--build-arg VCS_URL=$(VCS_URL) \
	--build-arg VCS_REF=$(VCS_REF) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--tag blueogive/texlive:2019 \
	--tag blueogive/texlive:$(TAG_DATE) \
	--tag blueogive/texlive:latest 2019/

push-2019 : build-2019
	@docker push blueogive/texlive:2019
	@docker push blueogive/texlive:latest
	@docker push blueogive/texlive:$(TAG_DATE)
