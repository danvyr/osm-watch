package fr.openstreetmap.watch;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.junit.Test;

public class MainTest {
    @Test
    public void a() {
        MainManager mm = new MainManager();
        mm.init();
        
        AlertDesc ad = new AlertDesc();
        ad.setUser("foo");
        
        mm.addAlert(ad);
    }
    
    public static void main(String[] args) {
        BasicConfigurator.configure();
        new MainTest().a();
    }
}
