import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

public class Main {
    static boolean print = true;
    static int width = 13;
    static int bit_depth = 12;
    static int romSize = (int) Math.pow(2, width);
    static PrintWriter pw;

    public static void main(String[] args) throws IOException {
        int amplitude = ((int) Math.pow(2, bit_depth)) / 2 - 1;
        if (print) {
            File file = new File("C:\\ECE2031\\ECE2031-Audio-Peripheral\\SOUND_SINE_" + width + "_BIT.mif");
            file.createNewFile();
            pw = new PrintWriter(file);
            pw.println("=-- Altera Memory Initialization File (MIF)\n" +
                    "DEPTH = " + romSize + ";\n" +
                    "WIDTH = " + bit_depth + ";\n" +
                    "ADDRESS_RADIX = DEC;\n" +
                    "DATA_RADIX = DEC;\n\n" +
                    "CONTENT\n" +
                    "BEGIN");
        }
        for (int i = 0; i < romSize; i++) {
            long sineRomValue = Math.round(Math.sin(Math.toRadians(360 * i / (double) romSize)) * amplitude);
            System.out.println("Mine: " + sineRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, sineRomValue);
            }
        }
        if (print) {
            pw.printf("END;");
            pw.close();
        }
    }
}