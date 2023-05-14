# Simple enum for storing OS types
enum OperatingSystemKernel
{
    Windows
    Linux
    macOS
}

# Custom error class for handling file not founds in a predictable way
class BrownserveFileNotFound: Exception
{
    [string]$FilePath

    BrownserveFileNotFound($Message, $FilePath) : base($Message) {
        $this.FilePath = $FilePath
    }

    BrownserveFileNotFound($Message) : base($Message) {
    }
}