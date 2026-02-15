# docker/nginx/Dockerfile
# Nginx web server for serving static files and proxying to Django

FROM nginx:1.25-alpine

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Create directories for static and media files
RUN mkdir -p /app/static /app/media && \
    chown -R nginx:nginx /app && \
    chmod -R 755 /app

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
