interface Particle {
  id: number;
  x: number;
  y: number;
  size: number;
  speed: number;
  opacity: number;
  direction: number;
}

@Component
export struct ParticleBackground {
  @State particles: Particle[] = []
  @State gridAnimOffset: number = 0
  private animTimer: number = -1
  private particleId: number = 0
  private readonly PARTICLE_COUNT: number = 20

  aboutToAppear() {
    this.initParticles()
    this.startAnimation()
  }

  aboutToDisappear() {
    if (this.animTimer !== -1) {
      clearInterval(this.animTimer)
    }
  }

  private initParticles() {
    for (let i = 0; i < this.PARTICLE_COUNT; i++) {
      this.particles.push(this.createParticle())
    }
  }

  private createParticle(): Particle {
    return {
      id: this.particleId++,
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: 2 + Math.random() * 4,
      speed: 0.1 + Math.random() * 0.3,
      opacity: 0.1 + Math.random() * 0.4,
      direction: Math.random() * 360
    }
  }

  private startAnimation() {
    this.animTimer = setInterval(() => {
      this.gridAnimOffset = (this.gridAnimOffset + 0.3) % 40
      const updated: Particle[] = []
      for (const p of this.particles) {
        const rad = p.direction * Math.PI / 180
        let newX = p.x + Math.cos(rad) * p.speed
        let newY = p.y + Math.sin(rad) * p.speed
        if (newX < -5) newX = 105
        if (newX > 105) newX = -5
        if (newY < -5) newY = 105
        if (newY > 105) newY = -5
        updated.push({
          id: p.id,
          x: newX,
          y: newY,
          size: p.size,
          speed: p.speed,
          opacity: p.opacity,
          direction: p.direction
        })
      }
      this.particles = updated
    }, 50)
  }

  build() {
    Stack() {
      Canvas(null)
        .width('100%')
        .height('100%')
        .onReady(() => {})

      ForEach(this.particles, (p: Particle) => {
        Circle()
          .width(p.size)
          .height(p.size)
          .fill(`rgba(255, 255, 255, ${p.opacity})`)
          .position({ x: `${p.x}%`, y: `${p.y}%` })
      }, (p: Particle) => p.id.toString())

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('transparent')
        .borderWidth(0)
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }
}

@Component
export struct GridOverlay {
  @State gridScrollOffset: number = 0
  private animTimer: number = -1

  aboutToAppear() {
    this.animTimer = setInterval(() => {
      this.gridScrollOffset = (this.gridScrollOffset + 0.2) % 40
    }, 50)
  }

  aboutToDisappear() {
    if (this.animTimer !== -1) {
      clearInterval(this.animTimer)
    }
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['rgba(102, 126, 234, 0.03)', 0.0],
            ['rgba(118, 75, 162, 0.03)', 1.0]
          ]
        })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)
  }
}