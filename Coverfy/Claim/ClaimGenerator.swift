import Foundation

enum ClaimGenerator {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    /// Draft claim letter for a defective product still under warranty (ES).
    static func buildClaim(for warranty: Warranty, defect: String) -> String {
        let purchase = dateFormatter.string(from: warranty.purchaseDate)
        let expiry = dateFormatter.string(from: warranty.expiryDate)
        let store = warranty.store.isEmpty ? "[Establecimiento]" : warranty.store
        return """
        RECLAMACIÓN POR PRODUCTO DEFECTUOSO EN GARANTÍA

        A la atención del servicio de atención al cliente de \(store):

        Por la presente le comunico que el producto "\(warranty.productName)", adquirido en su establecimiento el día \(purchase), ha dejado de funcionar correctamente.

        Descripción de la avería:
        \(defect)

        El producto se encuentra dentro del período de garantía legal (válida hasta el \(expiry)), por lo que, de conformidad con el Real Decreto-ley 7/2021 y la Ley General para la Defensa de los Consumidores y Usuarios, solicito la reparación o sustitución del producto sin coste alguno, o en su defecto la devolución del importe abonado.

        Adjunto copia del ticket de compra como prueba de adquisición.

        Quedo a la espera de su respuesta en un plazo máximo de 30 días.

        Atentamente,
        [Nombre y apellidos]
        [DNI]
        [Dirección / Email / Teléfono]
        """
    }
}
