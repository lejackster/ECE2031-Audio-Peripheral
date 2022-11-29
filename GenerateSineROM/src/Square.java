import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

public class Square {
    static boolean print = true;
    static int width = 13;
    static int bit_depth = 12;
    static int romSize = (int) Math.pow(2, width);
    static PrintWriter pw;

    public static void main(String[] args) throws IOException {
        int amplitude = ((int) Math.pow(2, bit_depth)) / 2 - 1;
        if (print) {
            File file = new File("C:\\Users\\tjkan\\OneDrive\\Desktop\\mepty\\School\\ECE2031\\ECE2031-Audio-Peripheral-main\\SOUND_SQUA_" + width + "_BIT.mif");
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
        for (int i = 0; i < romSize/2; i++) {
            long squareRomValue = -amplitude;
            System.out.println("Mine: " + squareRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, squareRomValue);
            }
        }
        for (int i = romSize/2; i < romSize; i++) {
            long squareRomValue = amplitude;
            System.out.println("Mine: " + squareRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, squareRomValue);
            }
        }
        if (print) {
            pw.printf("END;");
            pw.close();
        }
    }
}