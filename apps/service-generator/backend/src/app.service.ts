import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);

  getInfo() {
    this.logger.log('Info endpoint called');
    return {
      service: 'service-generator',
      version: process.env.APP_VERSION || 'dev',
      description: 'Example microservice following the Golden Path',
    };
  }
}
