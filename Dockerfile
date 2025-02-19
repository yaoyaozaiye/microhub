# 构建阶段
FROM maven:3.8.4-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 复制pom.xml
COPY pom.xml .

# 下载依赖
RUN mvn dependency:go-offline

# 复制源代码
COPY src ./src

# 构建应用
RUN mvn package -DskipTests

# 运行阶段
FROM openjdk:8-jre-slim

WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/storage-system-1.0.0.jar app.jar

# 创建数据目录
RUN mkdir -p /app/data

# 设置数据卷
VOLUME /app/data

# 暴露端口
EXPOSE 8080

# 设置启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
