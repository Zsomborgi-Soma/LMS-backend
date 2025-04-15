<?php
/**
 * router.php
 * 
 * Ez a fájl egy egyszerű routerként szolgál, amely kezeli a beérkező HTTP kéréseket, és továbbítja azokat a megfelelő vezérlőkhöz.
 * Meghatározza az alkalmazás API útvonalait, és összeköti azokat a megfelelő vezérlőmetódusokkal.
 * 
 * Funkciók:
 * - Kezeli az API végpontok útvonalait, beleértve a felhasználókezelést, könyvkezelést, kölcsönzéseket, foglalásokat és képek kezelését.
 * - Támogatja a többféle HTTP metódust (GET, POST, PUT, DELETE).
 * - Központosított helyet biztosít az API útvonalak definiálására és kezelésére.
 * - 404-es hibát ad vissza, ha a kért útvonal nem található.
 * 
 * Útvonalak:
 * - `/api/login`: Felhasználói bejelentkezés kezelése.
 * - `/api/register`: Felhasználói regisztráció kezelése.
 * - `/api/verify-account`: Fiók megerősítésének kezelése.
 * - `/api/forgot-password`: Jelszó-visszaállítási kérések kezelése.
 * - `/api/user`: Felhasználói adatok lekérése és frissítése.
 * - `/api/finalize-registration`: Regisztráció véglegesítése.
 * - `/api/change-password`: Jelszó módosításának kezelése.
 * - `/api/delete-user`: Felhasználó törlése.
 * - `/api/top-borrowings/{limit}`: Leggyakrabban kölcsönzött könyvek lekérése.
 * - `/api/borrowings`: Egy adott felhasználó kölcsönzéseinek lekérése.
 * - `/api/available-books`: Elérhető könyvek lekérése.
 * - `/api/upload-img`: Képfeltöltés kezelése.
 * - `/img/{ISBN}`: Könyv borítóképének lekérése.
 * - `/api/books`: Könyvek lekérése paraméterek alapján.
 * - `/api/all-books`: Az összes könyv számának lekérése.
 * - `/api/all-users`: Az összes felhasználó számának lekérése.
 * - `/api/all-borrowings`: Az összes kölcsönzés számának lekérése.
 * - `/api/reserve`: Könyvfoglalás kezelése.
 * 
 * Függőségek:
 * - `Router\Router`: Az útvonalak és kérések kezelése.
 * - `ApiResponse\Response`: API válaszok és hibaformázás kezelése.
 * - Vezérlők (Controllers): Az egyes funkciók kezelése (pl. `UserController`, `BooksController` stb.).
 */

require __DIR__ . '/vendor/autoload.php';
use Router\Router;
use ApiResponse\Response;
use App\Controllers\UserController;
use App\Controllers\BorrowingsController;
use App\Controllers\BooksController;
use App\Controllers\ImageController;
use App\Controllers\ReservationController;


Router::post("/api/login", UserController::class, "login");
Router::post("/api/register", UserController::class,"register");
Router::post("/api/verify-account", UserController::class,"verifyAccount");
Router::post("/api/forgot-password", UserController::class,"forgotPassword");
Router::get("/api/user", UserController::class,"userData", true);
Router::put("/api/user", UserController::class,"updateUser");
Router::put("/api/finalize-registration", UserController::class,"finalizeRegistration",false);
Router::put("/api/change-password", UserController::class,"changePassword");
Router::delete("/api/user", UserController::class,"deleteUser");


Router::get("/api/top-borrowings/{limit}", BorrowingsController::class,"topBorrowedBooks",false,true);

Router::get("/api/borrowings", BorrowingsController::class,"show",true);
Router::get("/api/available-books", BooksController::class,"availableBooks",false);

Router::post("/api/upload-img", ImageController::class,"uploadImg",false, true);
Router::get("/img/{ISBN}", ImageController::class,"getImg",false,true);


Router::get("/api/books", BooksController::class,"getFromDBByParams",false,true);
Router::get("/api/all-books", BooksController::class,"countAllBooks");
Router::get("/api/all-users", UserController::class,"allUsers");
Router::get("/api/all-borrowings", BorrowingsController::class,"allBorrowings");

Router::get("/api/reserve", ReservationController::class,"show",true);
Router::post("/api/reserve",ReservationController::class,"store",true);
Router::delete("/api/reserve/{ISBN}", ReservationController::class, "destroy");


Response::httpError(404, "Route not found");



?>