# 构建阶段
FROM maven:3.8.4-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

COPY settings.xml .

# 复制pom.xml
COPY pom.xml .

# 下载依赖
RUN mvn dependency:go-offline -s /app/settings.xml

# 复制源代码
COPY src ./src
COPY src-webui ./src-webui

# Download and install nvm:
RUN curl -fsSL https://gitee.com/sdq/nvm/raw/master/install.sh | bash \
    && . "$HOME/.nvm/nvm.sh" \
    && nvm install 22 \
    && node -v \
    && nvm current \
    && npm -v

WORKDIR /app/src-webui
# 构建应用
RUN npm install && npm run build

WORKDIR /app
RUN mvn clean package -DskipTests -s /app/settings.xml -P ci

# 运行阶段
FROM openjdk:8-jre-slim

WORKDIR /app

RUN cat <<EOF > /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye main non-free contrib
deb http://mirrors.aliyun.com/debian-security/ bullseye-security main
deb-src http://mirrors.aliyun.com/debian-security/ bullseye-security main
deb http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib
EOF

RUN apt-get update && \
    apt-get install -y bash curl wget net-tools iputils-ping git && \
    rm -rf /var/lib/apt/lists/*

# 从构建阶段复制jar文件
COPY --from=builder /app/target/*.jar app.jar

# 创建数据目录
RUN mkdir -p /app/data

# 设置数据卷
VOLUME /app/data

ENV SERVER_PORT=8081

# 暴露端口
EXPOSE 8081

# 设置启动命令
CMD ["sh", "-c", "java -jar app.jar --server.port=${SERVER_PORT}"]
