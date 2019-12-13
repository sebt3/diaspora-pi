FROM ruby:slim as build
COPY .tags /tmp/
COPY *.sh /bin/
RUN /bin/build.sh

FROM ruby:slim
RUN useradd -m diaspora											\
 && mkdir -p /usr/share/man/man1 /usr/share/man/man7							\
 && apt-get update											\
 && apt-get install -y imagemagick ghostscript curl nodejs ca-certificates postgresql-client 		\
	libssl1.1 libcurl4 libxml2 libxslt1.1 libmagickwand-6.q16-6 libpq5				\
 && rm -f /var/lib/apt/lists/*_Packages.*
COPY --chown=diaspora:diaspora --from=build /target/ /
ENTRYPOINT ["/bin/entrypoint.sh"]
