import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

public class Main {
    static boolean print = true;
    static int width = 13;
    static int bit_depth = 12;
    static int romSize = (int) Math.pow(2, width+2);
    static PrintWriter pw;

    public static void main(String[] args) throws IOException {
        float amplitude = ((int) Math.pow(2, bit_depth)) / 2 - 1;
        float Slope = 2 * amplitude / romSize;
        if (print) {
            File file = new File("C:\\Users\\tjkan\\OneDrive\\Desktop\\mepty\\School\\ECE2031\\ECE2031-Audio-Peripheral-main\\SOUND_WAVEFORM_" + width + "_BIT.mif");
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
        //SINE
        for (int i = 0; i < romSize/4; i++) {
            long sineRomValue = Math.round(Math.sin(Math.toRadians(360 * i * 4 / (double) romSize)) * amplitude);
            System.out.println("Mine: " + sineRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, sineRomValue);
            }
        }
        //SQUARE
        for (int i = romSize/4; i < 3*romSize/8; i++) {
            long squareRomValue = (int)-(amplitude/2);
            System.out.println("Mine: " + squareRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, squareRomValue);
            }
        }
        for (int i = 3*romSize/8; i < romSize/2; i++) {
            long squareRomValue = (int)(amplitude/2);
            System.out.println("Mine: " + squareRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, squareRomValue);
            }
        }
        //TRIANGLE
        for (int i = romSize/2; i < 5*romSize/8; i++) {
            long triRomValue = Math.round(-amplitude + (Slope * 8 * (i-(romSize/2))));
            System.out.println("Mine: " + triRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, triRomValue);
            }
        }
        for (int i = 5*romSize/8; i < 3*romSize/4; i++) {
            long triRomValue = Math.round(amplitude - (Slope * 8 * (i-(5*romSize/8))));
            System.out.println("Mine: " + triRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, triRomValue);
            }
        }
        //SAWTOOTH
        for (int i = 3*romSize/4; i < romSize; i++) {
            long sawRomValue = Math.round((-amplitude/2) + (Slope * 2 * (i-(romSize*3/4))));
            System.out.println("Mine: " + sawRomValue);
            if (print) {
                pw.printf("%d : %d;\n", i, sawRomValue);
            }
        }
        if (print) {
            pw.printf("END;");
            pw.close();
        }
    }
}