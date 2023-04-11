class LCurve {

  float a, b, phi, t, t_inc, j_inc, scale_a, scale_b;
  boolean adding;
  int col_inc, red, blue, green, col_chg;
  float a_low, a_high, a_inc;
  float scale_a_amp, scale_b_amp;
  
  LCurve(float a, float b, float phi, float t, float t_inc,
         float j_inc, float a_inc, float scale_a, float scale_b,
         boolean adding, int col_inc, int red, int green,
         int blue, int col_chg) {
         
        this.a = a;
        this.b = b;
        this.a_low = a;
        this.a_high = b;
        this.a_inc = a_inc;
        
        this.phi = phi;
        this.t = t;
        this.t_inc = t_inc;
        this.j_inc = j_inc;
        
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.col_inc = col_inc;
        
        this.scale_a = scale_a;
        this.scale_b = scale_b; 
        this.col_chg = col_chg;
  }
  
  void update(float amplitude, float[] spectrum) {
    if (spectrum[0] > 0.075 || amplitude > 0) {
       this.scale_a_amp = this.scale_a *spectrum[0]*12+amplitude*50;
       this.scale_b_amp = this.scale_b *spectrum[0]*12+amplitude*50;
       this.blue += random(20, 80);
    } else {
       this.scale_a_amp = this.scale_a;
       this.scale_b_amp = this.scale_b;
       this.blue = 100;
    }
    
    
    for (float j = this.t; j < this.t+(2*PI); j+= 0.1) {
      if (col_chg == 0) this.red = (this.red + this.col_inc) % 255;
      else if (col_chg == 1) this.green = (this.green + this.col_inc) % 255;
      
      
      stroke(this.red, this.green, this.blue);
      strokeWeight(random(1,2));

      
      line(this.scale_a_amp*sin(this.a*j + this.phi*(j/5000.0)), 
           this.scale_b_amp*sin(this.b*j), 
           this.scale_a_amp*sin(this.a*(j+this.j_inc) + this.phi*((j+this.j_inc)/5000.0)),
           this.scale_b_amp*sin(this.b*(j+this.j_inc)));
      //point(scale_a*sin(a*t + phi), scale_b*sin(b*t));
    }
    if (this.a > a_high) this.adding = false;
    else if (this.a <= a_low) this.adding = true;
    if (this.t > 10) this.t = 0.0;
    
    if (this.adding) this.a += this.a_inc;
    else this.a -= this.a_inc;
    this.t += this.t_inc;
  }

}
