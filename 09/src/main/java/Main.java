import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        InputStream inputStream = new InputStream();
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);
        EPDeployment deployment = compileAndDeploy(epRuntime,
                // 5
//                "select irstream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day)");
                // 6
//                "select irstream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('IBM', 'Honda', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 day)");
                // 7 a
//                "select irstream data, spolka, kursOtwarcia, kursZamkniecia " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day) " +
//                        "where kursZamkniecia > kursOtwarcia");
                // 7 b
//                "select irstream data, spolka, kursOtwarcia, kursZamkniecia " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day) " +
//                        "where KursAkcji.czyWzrostKursu(kursOtwarcia, kursZamkniecia)");
                // 8
//                "select irstream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)");
                // 9
//                "select irstream data, spolka, kursZamkniecia " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 day) " +
//                        "having max(kursZamkniecia) = kursZamkniecia");
                // 10
//                "select irstream max(kursZamkniecia) as maksimum " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days)");
                // 11
//                "select istream p.kursZamkniecia as kursPep, c.kursZamkniecia as kursCoc, p.data " +
//                        "from KursAkcji(spolka = 'PepsiCo').win:length(1) as p " +
//                        "join KursAkcji(spolka = 'CocaCola').win:length(1) as c " +
//                        "on p.data = c.data " +
//                        "where p.kursZamkniecia > c.kursZamkniecia");
                // 12
//                "select istream k.data, k.kursZamkniecia as kursBiezacy, k.spolka, k.kursZamkniecia - initial.kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:length(1) as k " +
//                        "join KursAkcji(spolka in ('PepsiCo', 'CocaCola')).std:firstunique(spolka) as initial " +
//                        "on k.spolka = initial.spolka");
                // 13
//                "select istream k.data, k.kursZamkniecia as kursBiezacy, k.spolka, k.kursZamkniecia - initial.kursZamkniecia as roznica " +
//                        "from KursAkcji.win:length(1) as k " +
//                        "join KursAkcji.std:firstunique(spolka) as initial " +
//                        "on k.spolka = initial.spolka " +
//                        "where k.kursZamkniecia > initial.kursZamkniecia");
                // 14
//                "select istream a.data as dataA, b.data as dataB, a.kursOtwarcia as kursA, b.kursOtwarcia as kursB, a.spolka as spolka " +
//                        "from KursAkcji.win:ext_timed(data.getTime(), 7 days) as a " +
//                        "join KursAkcji.win:ext_timed(data.getTime(), 7 days) as b " +
//                        "on a.spolka = b.spolka " +
//                        "where b.kursOtwarcia - a.kursOtwarcia > 3");
                // 15
//                "select istream data, spolka, obrot " +
//                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
//                        "order by obrot desc limit 3");
                // 16
                "select istream data, spolka, obrot " +
                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc limit 1 offset 2");
        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }
        inputStream.generuj(epRuntime.getEventService());
    }

    private static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            return deploymentService.deploy(epCompiled);
        } catch (EPCompileException | EPDeployException e) {
            throw new RuntimeException(e);
        }
    }
}
