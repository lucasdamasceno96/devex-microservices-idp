import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('health', () => {
    it('should return healthy status', () => {
      const result = appController.health();
      expect(result.status).toBe('healthy');
      expect(result.timestamp).toBeDefined();
      expect(result.uptime).toBeGreaterThanOrEqual(0);
    });
  });

  describe('metrics', () => {
    it('should return metrics', () => {
      const result = appController.metrics();
      expect(result.uptime).toBeGreaterThanOrEqual(0);
      expect(result.memory).toBeDefined();
      expect(result.version).toBeDefined();
    });
  });
});
