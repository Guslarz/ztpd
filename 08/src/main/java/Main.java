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
                "select istream data, spolka, 2 * kursOtwarcia - sum(kursOtwarcia) as roznica " +
                        "from KursAkcji(spolka = 'Oracle').win:length(2) " +
                        "having kursOtwarcia = max(kursOtwarcia) " +
                        "and kursOtwarcia != sum(kursOtwarcia)");
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
