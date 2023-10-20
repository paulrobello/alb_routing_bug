FROM public.ecr.aws/lambda/python:3.11-x86_64

ENV LAMBDA_HOME=/usr/local/lhome
ARG HANDLER_NAME=handler

RUN --mount=type=cache,target=/var/cache/yum \
    yum makecache && \
    yum update -y && \
    yum install zip -y

RUN mkdir -p ${LAMBDA_HOME}/dist/requirements
WORKDIR ${LAMBDA_HOME}/dist
#
# We only want to copy src/requirements.txt when it exists.
#
COPY src/* requirements/

# Some dependencies bring boto3 in but the Lambda runtimes includes it already, so delete it from the Lambda zipfile
RUN rm -rf ${LAMBDA_HOME}/package2/boto*
RUN rm -rf ${LAMBDA_HOME}/package2/simplejson/tests*
RUN rm -rf ${LAMBDA_HOME}/dist/requirements


WORKDIR $LAMBDA_HOME
COPY src dist

WORKDIR ${LAMBDA_HOME}/dist
RUN zip  -r ../${HANDLER_NAME}.zip * -x "*.txt"

WORKDIR ${LAMBDA_HOME}
RUN if test -e package2; \
    then \
      cd package2 && zip -ur ../${HANDLER_NAME}.zip .; \
    fi
