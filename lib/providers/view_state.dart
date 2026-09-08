/// Mismo patrón que usaba el código base del profe (_isLoading / _errorMessage),
/// pero expresado como una máquina de estados explícita en vez de dos flags sueltos.
enum ViewState { initial, loading, success, error, empty }
