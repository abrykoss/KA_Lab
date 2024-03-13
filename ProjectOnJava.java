/*Прочитати з stdin N десяткових чисел, розділених пробілом чи новим рядком до появи EOF (макс довжина рядка 255 символів), кількість чисел може до 10000.
 Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
Кожне число це ціле десяткове знакове число, яке треба конвертувати в бінарне представлення (word в доповнювальному коді).
Від'ємні числа починаються з '-'.
Увага: якщо число занадто велике за модулем для 16-бітного представлення зі знаком, таке значення має бути представлене як максимально можливе (за модулем).
Відсортувати бінарні значення алгоритмом bubble sort (asc).
Обчислити значення медіани та вивести десяткове в консоль як рядок (stdout)
Обчислити середнє значення та вивести десяткове в консоль як рядок (stdout)*/
import java.util.Scanner;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class ProjectOnJava {
    public static void main (String[] args) {
System.out.println("Введіть кількість чисел");
        Scanner scanner = new Scanner(System.in);
        int n = scanner.nextInt();
        int[] arr = new int[n];
        System.out.println("Введіть числа");
        for (int i = 0; i < n; i++) {
            arr[i] = scanner.nextInt();
        }
        //Convert to binary
        for (int i = 0; i < n; i++) {
            if (arr[i] < 0) {
                arr[i] = 65536 + arr[i];
            }
        }
        //Bubble sort
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }
        for (int i = 0; i < n; i++) {
            System.out.println("Бінарне предтставлення числа " + arr[i] + " :");
            System.out.println(Integer.toBinaryString(arr[i]));
        }
        //Вивести відсортований масив
        System.out.println("Відсортований масив:");
        for (int i = 0; i < n; i++) {
            System.out.println(arr[i]);
        }
        int sum = 0;
        for (int i = 0; i < n; i++) {
            sum += arr[i];
        }
        System.out.println("Середнє значення: " + sum / n);
        System.out.println("Медіана: " + arr[n / 2]);
    }
}
